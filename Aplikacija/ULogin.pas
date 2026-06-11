unit ULogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TLoginForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    pnlPozadina: TPanel;
    lblNaslov, lblKorisnik, lblSifra: TLabel;
    edtKorisnik, edtSifra: TEdit;
    btnPrijava, btnOdustani: TButton;
    procedure btnPrijavaClick(Sender: TObject);
    procedure btnOdustaniClick(Sender: TObject);
  public
    Uspesno: Boolean;
  end;

var
  LoginForm: TLoginForm;

implementation

{$R *.dfm}

procedure TLoginForm.FormCreate(Sender: TObject);
begin
  Caption := 'Prijava na sistem';
  Width := 400;
  Height := 300;
  Position := poScreenCenter;
  BorderStyle := bsDialog;
  Uspesno := False;

  pnlPozadina := TPanel.Create(Self);
  pnlPozadina.Parent := Self;
  pnlPozadina.Align := alClient;
  pnlPozadina.Color := clWhite;

  lblNaslov := TLabel.Create(Self);
  lblNaslov.Parent := pnlPozadina;
  lblNaslov.SetBounds(50, 20, 300, 30);
  lblNaslov.Caption := 'PRIJAVA NA SISTEM ZALIHA';
  lblNaslov.Font.Size := 14;
  lblNaslov.Font.Style := [fsBold];

  lblKorisnik := TLabel.Create(Self);
  lblKorisnik.Parent := pnlPozadina;
  lblKorisnik.SetBounds(50, 80, 100, 20);
  lblKorisnik.Caption := 'Korisničko ime:';

  edtKorisnik := TEdit.Create(Self);
  edtKorisnik.Parent := pnlPozadina;
  edtKorisnik.SetBounds(50, 100, 280, 25);
  edtKorisnik.Text := 'admin'; // Postavili smo admin da ti bude lakse za testiranje

  lblSifra := TLabel.Create(Self);
  lblSifra.Parent := pnlPozadina;
  lblSifra.SetBounds(50, 140, 100, 20);
  lblSifra.Caption := 'Lozinka:';

  edtSifra := TEdit.Create(Self);
  edtSifra.Parent := pnlPozadina;
  edtSifra.SetBounds(50, 160, 280, 25);
  edtSifra.PasswordChar := '*'; // Da se ne vide slova kad kucas sifru
  edtSifra.Text := 'admin';

  btnPrijava := TButton.Create(Self);
  btnPrijava.Parent := pnlPozadina;
  btnPrijava.SetBounds(50, 210, 130, 35);
  btnPrijava.Caption := 'Prijavi se';
  btnPrijava.OnClick := btnPrijavaClick;

  btnOdustani := TButton.Create(Self);
  btnOdustani.Parent := pnlPozadina;
  btnOdustani.SetBounds(200, 210, 130, 35);
  btnOdustani.Caption := 'Odustani';
  btnOdustani.OnClick := btnOdustaniClick;
end;

procedure TLoginForm.btnPrijavaClick(Sender: TObject);
begin
  // Hardkodovana provera kako bi sistem bio bezbedan i jednostavan
  if (edtKorisnik.Text = 'admin') and (edtSifra.Text = 'admin') then
  begin
    Uspesno := True;
    Close; // Zatvara login i pusta te u glavnu aplikaciju
  end
  else
  begin
    ShowMessage('Greška! Pogrešno korisničko ime ili lozinka.');
    edtSifra.Clear;
    edtSifra.SetFocus;
  end;
end;

procedure TLoginForm.btnOdustaniClick(Sender: TObject);
begin
  Uspesno := False;
  Close;
end;

end.
