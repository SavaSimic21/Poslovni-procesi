program ZalihePro;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {MainForm},
  UDataModule in 'UDataModule.pas' {DM: TDataModule},
  ULogin in 'ULogin.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  // VAZNO: Baza (DM) mora da se kreira prva, da bi glavna forma mogla da je koristi!
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
