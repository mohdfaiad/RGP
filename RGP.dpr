program RGP;

uses
  System.StartUpCopy,
  FMX.Forms,
  U_Log in 'U_Log.pas' {Log},
  U_MainB in 'U_MainB.pas' {MainB},
  U_Ins in 'U_Ins.pas' {Ins},
  U_DataModule in 'U_DataModule.pas' {DataModule1: TDataModule},
  U_Main in 'U_Main.pas' {Main},
  U_Option in 'U_Option.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TLog, Log);
  Application.CreateForm(TMainB, MainB);
  Application.CreateForm(TIns, Ins);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
