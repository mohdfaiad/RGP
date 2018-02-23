unit U_DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.UITypes, FMX.Dialogs, FMX.Types, FMX.Controls,
  IdHashMessageDigest;

type
  TDataModule1 = class(TDataModule)
    FDConnection1: TFDConnection;
    FDCommand1: TFDCommand;
    FDQuery1: TFDQuery;
    Windows10: TStyleBook;
    Windows10Grey: TStyleBook;
    FDConnection2: TFDConnection;
    FDQ_Wilaya: TFDQuery;
    FDQ_Commune: TFDQuery;
    FDQ_Entreprise: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

function Encryt(Str: string): string;
var
  Md5: TIdHashMessageDigest5;
  Hash: string;
begin
  Md5 := TIdHashMessageDigest5.Create;
  Hash := Md5.HashStringAsHex(Str);
  Result := Hash;
end;

procedure TDataModule1.DataModuleCreate(Sender: TObject);
var
  Path, PathInf, DirPath, HexPass, Db_Entrprise: string;
  Contact, Patient, Biochimie, Entreprise, Hemogramme, Hemostase_VS,
    Serologie: String;
begin
  // Asigne Tables to Varibales
  Contact :=
    ('CREATE TABLE `User`(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, Nom varchar(20), Pseudo varchar(10), Mot_de_pass varchar(12)); ');
  Patient :=
    ('CREATE TABLE `Patient`(`Patient_ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,`Nom`	Varchar ( 15 ),`Prenom`	varchar ( 20 ),`Date_de_Nai`	varchar ( 10 ),`Date_de_Entre`	varchar ( 10 ),`Type`	'
    + 'varchar ( 100 ),`Sexe`	varchar ( 5 ),`Etat_Civil`	varchar ( 13 ),`Wilaya`	varchar ( 20 ),`Commune`	varchar ( 20 ),`Adresse`	varchar ( 50 ),`Mobile`	INTEGER,`Email`	varchar ( 35 ),Groupage varchar(5),Telephone Integer(9), Fax Integer(13));');
  Biochimie :=
    ('CREATE TABLE `Biochimie` (`Biochimi_ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,`Glycemie`	INTEGER,`Uree_Sang`	INTEGER,`Createnine`	INTEGER,`Cholesterole`	INTEGER,`Triglycerides`	INTEGER,`HDL`	INTEGER,`LDL`	INTEGER,'
    + '`Acide_Urique`	INTEGER,`CRP`	INTEGER,`TGO`	INTEGER,`TGP`	INTEGER,`PAL`	INTEGER,`TP`	INTEGER,`INR`	INTEGER,`BilirubineT`	INTEGER,`BilirubineD`	INTEGER,`ASLO`	INTEGER,`Calcemie`	INTEGER,`Albuminemie`	INTEGER);');
  Entreprise :=
    ('CREATE TABLE `Entreprise` (`ID_EntreP`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,`Form_Juridique`	varchar ( 10 ),'
    + '`Libelle`	varchar ( 40 ),`Libelle_Sec`	varchar ( 40 ),`Wilaya`	varchar ( 20 ),`Code_de_Wilaya`	Integer ( 3 ),`Commune`	varchar ( 20 ),'
    + '`Code_Postal`	Integer ( 7 ),`Adresse`	varchar ( 100 ),`Telephone`	Integer ( 13 ),`Mobile`	Integer ( 13 ),`Fax`	Integer ( 13 ),`Email`	varchar ( 30 ),`Web`	varchar ( 40 ));');
  Hemogramme :=
    ('CREATE TABLE `Hemogramme` (`HemoG_ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,`Hematies`	INTEGER,`Hemoglobine`	INTEGER,`Hematocrite`	INTEGER,`VGM`	INTEGER,`TCMH`	INTEGER,`CCMH`	INTEGER,`Leucocytes`	INTEGER,`Reticulocytes`	INTEGER);');
  Hemostase_VS :=
    ('CREATE TABLE `Hemostase-VS` (`HemoS_VS_ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,`TS`	INTEGER,`TCK`	INTEGER,`TP`	INTEGER,`VS`	INTEGER,`Note`	BLOB);');
  Serologie :=
    ('CREATE TABLE `Serologie` (`Serologie_ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,`HA_Anti-VHA`	boolean,`HA_IgG`	boolean,'
    + '`HA_IgM`	boolean,`HB_Anti-VHB`	Boolean,`HB_Antigene_HBs`	boolean,`HC_Anit-VHC`	boolean,`VIH_Anti-VIH`	boolean,`RUB_Anti_M`	boolean,`RUB_Anti_A`	boolean,`RUB_Anti_G`	boolean,`Salm_Anti_H`	boolean,`Salm_Anti_O`	boolean,'
    + '`Mono_Anti_EBV`	boolean,`Mono_Anti_G_Anti_VCA`	boolean,`Mono_Anti_G_Anti_EBNA`	boolean,`Mono_Anti_G_Anti_EA`	boolean,`Toxo_Anti_M`	boolean);');

  // Database Anitialse and Location
  DirPath := GetEnvironmentVariable('AppData');
  CreateDir(DirPath + '\RGP_Data');
  Path := (DirPath + '\RGP_Data\Data.db');
  Db_Entrprise := ExpandFileName(GetCurrentDir() + '\Data\Entreprise.db');
  PathInf := ExpandFileName(GetCurrentDir() + '\Data\Alg_info.db');
  FDConnection1.Params.Add('Database=' + Path);
  FDConnection2.Params.Add('Database=' + PathInf);
  FDConnection1.Connected := True;
  FDConnection2.Connected := True;

  { ---------------| Test Database and Tables |------------------- }
  // Account Database and Tabes
  try
    FDQuery1.Close;
    FDQuery1.SQL.Text := ('Select * From User');
    FDQuery1.Active := True;
  except
    on E: Exception do
    begin
      FDQuery1.Close;
      try
        FDCommand1.Connection := FDConnection1;
        FDCommand1.CommandText.Text :=
          (Contact + Patient + Biochimie + Entreprise + Hemogramme +
          Hemostase_VS + Serologie);
        FDCommand1.Execute();
        with FDQuery1 do
        begin
          // Anitialise the Admin account
          HexPass := Encryt('admin'); // Encrypt Admin password
          SQL.Text := ('Select * From User');
          Active := True;
          Insert;
          FieldByName('Nom').AsString := ('Computer');
          FieldByName('Pseudo').AsString := ('admin');
          FieldByName('Mot_de_pass').AsString := HexPass;
          Post;
          Active := False;
        end;
      except
        on E: Exception do

      end;
    end;
  end;
end;

end.
