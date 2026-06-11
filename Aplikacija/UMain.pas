unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    pnlStats: TPanel;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlIstorijaBar: TPanel;
    lblIstorija: TLabel;
    lblPretraga: TLabel;
    lblKategorija: TLabel;
    edtPretraga: TEdit;
    cmbKategorija: TComboBox;
    grdZalihe: TDBGrid;
    grdIstorija: TDBGrid;

    btnPrijemnica: TButton;
    btnOtpremnica: TButton;
    btnNoviArtikal: TButton;
    btnIzvoz: TButton;
    btnNivelacija: TButton;
    btnStorniraj: TButton;

    qryStanje: TFDQuery;
    dsStanje: TDataSource;

    qryIstorija: TFDQuery;
    dsIstorija: TDataSource;

    procedure OsveziStanje;
    procedure OsveziStatistiku;
    procedure grdZaliheDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure grdIstorijaDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure qryStanjeAfterScroll(DataSet: TDataSet);
    procedure btnPrijemnicaClick(Sender: TObject);
    procedure btnOtpremnicaClick(Sender: TObject);
    procedure btnNoviArtikalClick(Sender: TObject);
    procedure btnNivelacijaClick(Sender: TObject);
    procedure btnIzvozClick(Sender: TObject);
    procedure btnStornirajClick(Sender: TObject);
    procedure edtPretragaChange(Sender: TObject);
    procedure cmbKategorijaChange(Sender: TObject);
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  UDataModule, ULogin;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  LogForm: TLoginForm;
begin
  LogForm := TLoginForm.Create(nil);
  try
    LogForm.ShowModal;
    if not LogForm.Uspesno then
    begin
      Application.Terminate;
      Exit;
    end;
  finally
    LogForm.Free;
  end;

  Caption := 'Informacioni Sistem Zaliha - Poslovni Procesi';
  Width := 1150;
  Height := 750;
  Position := poScreenCenter;
  Font.Size := 10;
  Color := clBtnFace;

  pnlStats := TPanel.Create(Self);
  pnlStats.Parent := Self;
  pnlStats.Align := alTop;
  pnlStats.Height := 40;
  pnlStats.Color := $00400000;
  pnlStats.ParentBackground := False;
  pnlStats.Font.Color := clWhite;
  pnlStats.Font.Style := [fsBold];
  pnlStats.Caption := 'Učitavanje statistike...';

  pnlTop := TPanel.Create(Self);
  pnlTop.Parent := Self;
  pnlTop.Align := alTop;
  pnlTop.Height := 110;
  pnlTop.Caption := '';
  pnlTop.BevelOuter := bvNone;
  pnlTop.Color := clWhite;
  pnlTop.ParentBackground := False;

  btnPrijemnica := TButton.Create(Self);
  btnPrijemnica.Parent := pnlTop;
  btnPrijemnica.SetBounds(25, 15, 170, 40);
  btnPrijemnica.Caption := '📥 PRIJEM (ULAZ)';
  btnPrijemnica.Font.Style := [fsBold];
  btnPrijemnica.OnClick := btnPrijemnicaClick;

  btnOtpremnica := TButton.Create(Self);
  btnOtpremnica.Parent := pnlTop;
  btnOtpremnica.SetBounds(205, 15, 170, 40);
  btnOtpremnica.Caption := '📤 OTPREMA (IZLAZ)';
  btnOtpremnica.Font.Style := [fsBold];
  btnOtpremnica.OnClick := btnOtpremnicaClick;

  btnNoviArtikal := TButton.Create(Self);
  btnNoviArtikal.Parent := pnlTop;
  btnNoviArtikal.SetBounds(385, 15, 170, 40);
  btnNoviArtikal.Caption := '➕ NOVI ARTIKAL';
  btnNoviArtikal.Font.Style := [fsBold];
  btnNoviArtikal.OnClick := btnNoviArtikalClick;

  btnNivelacija := TButton.Create(Self);
  btnNivelacija.Parent := pnlTop;
  btnNivelacija.SetBounds(565, 15, 170, 40);
  btnNivelacija.Caption := '🏷️ PROMENA CENE';
  btnNivelacija.Font.Style := [fsBold];
  btnNivelacija.OnClick := btnNivelacijaClick;

  btnIzvoz := TButton.Create(Self);
  btnIzvoz.Parent := pnlTop;
  btnIzvoz.SetBounds(745, 15, 170, 40);
  btnIzvoz.Caption := '💾 IZVOZ U CSV';
  btnIzvoz.Font.Style := [fsBold];
  btnIzvoz.OnClick := btnIzvozClick;

  lblPretraga := TLabel.Create(Self);
  lblPretraga.Parent := pnlTop;
  lblPretraga.SetBounds(25, 70, 60, 20);
  lblPretraga.Caption := 'Pretraga:';
  lblPretraga.Font.Style := [fsBold];

  edtPretraga := TEdit.Create(Self);
  edtPretraga.Parent := pnlTop;
  edtPretraga.SetBounds(95, 67, 300, 25);
  edtPretraga.OnChange := edtPretragaChange;

  lblKategorija := TLabel.Create(Self);
  lblKategorija.Parent := pnlTop;
  lblKategorija.SetBounds(425, 70, 70, 20);
  lblKategorija.Caption := 'Kategorija:';
  lblKategorija.Font.Style := [fsBold];

  cmbKategorija := TComboBox.Create(Self);
  cmbKategorija.Parent := pnlTop;
  cmbKategorija.SetBounds(505, 67, 200, 25);
  cmbKategorija.Style := csDropDownList;
  cmbKategorija.Items.Add('Sve kategorije');
  cmbKategorija.Items.Add('Obuća');
  cmbKategorija.Items.Add('Odeća');
  cmbKategorija.Items.Add('Oprema');
  cmbKategorija.ItemIndex := 0;
  cmbKategorija.OnChange := cmbKategorijaChange;

  pnlBottom := TPanel.Create(Self);
  pnlBottom.Parent := Self;
  pnlBottom.Align := alBottom;
  pnlBottom.Height := 250;
  pnlBottom.BevelOuter := bvNone;

  pnlIstorijaBar := TPanel.Create(Self);
  pnlIstorijaBar.Parent := pnlBottom;
  pnlIstorijaBar.Align := alTop;
  pnlIstorijaBar.Height := 40;
  pnlIstorijaBar.Caption := '';
  pnlIstorijaBar.BevelOuter := bvNone;
  pnlIstorijaBar.Color := $00F0F0F0;
  pnlIstorijaBar.ParentBackground := False;

  lblIstorija := TLabel.Create(Self);
  lblIstorija.Parent := pnlIstorijaBar;
  lblIstorija.Align := alLeft;
  lblIstorija.Layout := tlCenter;
  lblIstorija.Caption := '  📜 ISTORIJA PROMETA:';
  lblIstorija.Font.Style := [fsBold];
  lblIstorija.Font.Color := clNavy;

  btnStorniraj := TButton.Create(Self);
  btnStorniraj.Parent := pnlIstorijaBar;
  btnStorniraj.Left := 210;
  btnStorniraj.Top := 5;
  btnStorniraj.Width := 180;
  btnStorniraj.Height := 30;
  btnStorniraj.Caption := '🗑️ STORNIRAJ DOKUMENT';
  btnStorniraj.OnClick := btnStornirajClick;

  grdIstorija := TDBGrid.Create(Self);
  grdIstorija.Parent := pnlBottom;
  grdIstorija.Align := alClient;
  grdIstorija.Options := [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack];
  grdIstorija.TitleFont.Style := [fsBold];
  grdIstorija.OnDrawColumnCell := grdIstorijaDrawColumnCell;

  grdZalihe := TDBGrid.Create(Self);
  grdZalihe.Parent := Self;
  grdZalihe.Align := alClient;
  grdZalihe.Options := [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack];
  grdZalihe.TitleFont.Style := [fsBold];
  grdZalihe.OnDrawColumnCell := grdZaliheDrawColumnCell;

  qryStanje := TFDQuery.Create(Self);
  qryStanje.Connection := DM.Konekcija;
  qryStanje.AfterScroll := qryStanjeAfterScroll;

  dsStanje := TDataSource.Create(Self);
  dsStanje.DataSet := qryStanje;
  grdZalihe.DataSource := dsStanje;

  qryIstorija := TFDQuery.Create(Self);
  qryIstorija.Connection := DM.Konekcija;

  dsIstorija := TDataSource.Create(Self);
  dsIstorija.DataSet := qryIstorija;
  grdIstorija.DataSource := dsIstorija;

  OsveziStanje;
end;

procedure TMainForm.grdZaliheDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  grdZalihe.Canvas.Brush.Color := clWindow;
  grdZalihe.Canvas.Font.Color := clWindowText;

  if gdSelected in State then
  begin
    grdZalihe.Canvas.Brush.Color := clHighlight;
    grdZalihe.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    if qryStanje.FieldByName('TrenutnoStanje').AsInteger < 5 then
    begin
      grdZalihe.Canvas.Brush.Color := clWebMistyRose;
      grdZalihe.Canvas.Font.Color := clBlack;
    end
    else if qryStanje.RecNo mod 2 = 0 then
    begin
      grdZalihe.Canvas.Brush.Color := $00F9F9F9;
    end;
  end;

  grdZalihe.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TMainForm.grdIstorijaDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if (not (gdSelected in State)) then
  begin
     if qryIstorija.RecNo mod 2 = 0 then
        grdIstorija.Canvas.Brush.Color := $00F9F9F9;
  end;
  grdIstorija.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TMainForm.OsveziStatistiku;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.Konekcija;
    Q.SQL.Text := 'SELECT COALESCE(SUM(a.Cena * s.Kolicina * s.UlazIzlaz), 0) as Vrednost FROM StavkeDokumenta s JOIN Artikli a ON s.Artikal_ID = a.ID';
    Q.Open;
    pnlStats.Caption := '  📊 UKUPNA VREDNOST MAGACINA: ' + Q.FieldByName('Vrednost').AsString + ' RSD';
  finally
    Q.Free;
  end;
end;

procedure TMainForm.OsveziStanje;
var
  FilterTxt, SQLQry: string;
begin
  FilterTxt := Trim(edtPretraga.Text);
  qryStanje.Close;

  SQLQry := 'SELECT a.ID, a.Sifra, a.Vrsta_Artikla as Kategorija, a.Naziv, a.JedinicaMere, a.Cena, ' +
            'COALESCE(SUM(s.Kolicina * s.UlazIzlaz), 0) as TrenutnoStanje ' +
            'FROM Artikli a ' +
            'LEFT JOIN StavkeDokumenta s ON a.ID = s.Artikal_ID WHERE 1=1 ';

  if FilterTxt <> '' then
    SQLQry := SQLQry + 'AND (a.Naziv LIKE ''%' + FilterTxt + '%'' OR a.Sifra LIKE ''%' + FilterTxt + '%'') ';

  if cmbKategorija.ItemIndex > 0 then
    SQLQry := SQLQry + 'AND a.Vrsta_Artikla = ''' + cmbKategorija.Text + ''' ';

  SQLQry := SQLQry + 'GROUP BY a.ID, a.Sifra, a.Vrsta_Artikla, a.Naziv, a.JedinicaMere, a.Cena';

  qryStanje.SQL.Text := SQLQry;
  qryStanje.Open;

  qryStanje.FieldByName('ID').Visible := False;
  OsveziStatistiku;
end;

procedure TMainForm.edtPretragaChange(Sender: TObject);
begin
  OsveziStanje;
end;

procedure TMainForm.cmbKategorijaChange(Sender: TObject);
begin
  OsveziStanje;
end;

procedure TMainForm.qryStanjeAfterScroll(DataSet: TDataSet);
begin
  if qryStanje.IsEmpty then
  begin
    qryIstorija.Close;
    Exit;
  end;

  qryIstorija.Close;
  qryIstorija.SQL.Text :=
    'SELECT d.ID as DokumentID, d.Datum, d.TipDokumenta, d.BrojDokumenta, ' +
    'COALESCE(d.ImePartnera, p.Naziv) as Partner, ' +
    's.Kolicina, CASE WHEN d.TipDokumenta = ''NIVELACIJA'' THEN ''CENA'' WHEN s.UlazIzlaz = 1 THEN ''ULAZ'' ELSE ''IZLAZ'' END as Smer ' +
    'FROM StavkeDokumenta s ' +
    'JOIN Dokumenti d ON s.Dokument_ID = d.ID ' +
    'LEFT JOIN Partneri p ON d.Partner_ID = p.ID ' +
    'WHERE s.Artikal_ID = ' + IntToStr(qryStanje.FieldByName('ID').AsInteger) + ' ' +
    'ORDER BY d.ID DESC';
  qryIstorija.Open;

  if not qryIstorija.IsEmpty then
    qryIstorija.FieldByName('DokumentID').Visible := False;
end;

procedure TMainForm.btnNoviArtikalClick(Sender: TObject);
var
  Sifra, Naziv, Kat, JM, CenaStr: string;
  Cena: Integer;
begin
  Kat := InputBox('➕ Novi artikal', 'Unesite kategoriju (Obuća, Odeća ili Oprema):', 'Obuća');
  if Kat = '' then Exit;

  Sifra := InputBox('➕ Novi artikal', 'Unesite šifru artikla:', '');
  if Sifra = '' then Exit;

  Naziv := InputBox('➕ Novi artikal', 'Unesite pun naziv artikla:', '');
  if Naziv = '' then Exit;

  JM := InputBox('➕ Novi artikal', 'Unesite jedinicu mere:', 'kom');
  if JM = '' then Exit;

  CenaStr := InputBox('➕ Novi artikal', 'Unesite prodajnu cenu:', '0');
  if not TryStrToInt(CenaStr, Cena) then Cena := 0;

  DM.IzvrsiUpit('INSERT INTO Artikli (Sifra, Vrsta_Artikla, Naziv, JedinicaMere, Cena) ' +
                'VALUES (''' + Sifra + ''', ''' + Kat + ''', ''' + Naziv + ''', ''' + JM + ''', ' + IntToStr(Cena) + ')');
  OsveziStanje;
end;

procedure TMainForm.btnNivelacijaClick(Sender: TObject);
var
  NovaCenaStr: string;
  NovaCena, OdabraniArtikalID, StaraCena, DokumentID: Integer;
begin
  if qryStanje.IsEmpty then Exit;

  OdabraniArtikalID := qryStanje.FieldByName('ID').AsInteger;
  StaraCena := qryStanje.FieldByName('Cena').AsInteger;

  NovaCenaStr := InputBox('🏷️ Nivelacija (Promena Cene)',
                          'Trenutna cena iznosi: ' + IntToStr(StaraCena) + sLineBreak + 'Unesite novu prodajnu cenu:',
                          IntToStr(StaraCena));

  if TryStrToInt(NovaCenaStr, NovaCena) and (NovaCena > 0) and (NovaCena <> StaraCena) then
  begin
    DM.IzvrsiUpit('UPDATE Artikli SET Cena = ' + IntToStr(NovaCena) + ' WHERE ID = ' + IntToStr(OdabraniArtikalID));

    DM.IzvrsiUpit('INSERT INTO Dokumenti (TipDokumenta, BrojDokumenta, Datum, Partner_ID, ImePartnera) ' +
                  'VALUES (''NIVELACIJA'', ''NV-' + FormatDateTime('yymmddhhnnss', Now) + ''', DATE(''now''), NULL, ''PROMENA CENE'')');

    DokumentID := DM.Konekcija.ExecSQLScalar('SELECT last_insert_rowid()');

    DM.IzvrsiUpit('INSERT INTO StavkeDokumenta (Dokument_ID, Artikal_ID, Kolicina, UlazIzlaz) ' +
                  'VALUES (' + IntToStr(DokumentID) + ', ' + IntToStr(OdabraniArtikalID) + ', 0, 0)');

    OsveziStanje;
    ShowMessage('🏷️ Cena je uspešno promenjena!');
  end;
end;

procedure TMainForm.btnPrijemnicaClick(Sender: TObject);
var
  UnosKolicine, UnosPartnera: string;
  Kolicina, DokumentID, OdabraniArtikalID: Integer;
begin
  if qryStanje.IsEmpty then Exit;

  OdabraniArtikalID := qryStanje.FieldByName('ID').AsInteger;

  UnosPartnera := InputBox('Prijemnica', 'Od koga se vrši nabavka (Naziv Dobavljača):', 'Sport Vision d.o.o.');
  if UnosPartnera = '' then Exit;

  UnosKolicine := InputBox('Prijemnica', 'Unesite količinu za ulaz:', '10');

  if TryStrToInt(UnosKolicine, Kolicina) and (Kolicina > 0) then
  begin
    DM.IzvrsiUpit('INSERT INTO Dokumenti (TipDokumenta, BrojDokumenta, Datum, Partner_ID, ImePartnera) ' +
                  'VALUES (''PRIJEMNICA'', ''PR-' + FormatDateTime('yymmddhhnnss', Now) + ''', DATE(''now''), 1, ''' + UnosPartnera + ''')');

    DokumentID := DM.Konekcija.ExecSQLScalar('SELECT last_insert_rowid()');

    DM.IzvrsiUpit('INSERT INTO StavkeDokumenta (Dokument_ID, Artikal_ID, Kolicina, UlazIzlaz) ' +
                  'VALUES (' + IntToStr(DokumentID) + ', ' + IntToStr(OdabraniArtikalID) + ', ' + IntToStr(Kolicina) + ', 1)');
    OsveziStanje;
  end;
end;

procedure TMainForm.btnOtpremnicaClick(Sender: TObject);
var
  UnosKolicine, UnosPartnera: string;
  Kolicina, DokumentID, OdabraniArtikalID, Trenutno: Integer;
begin
  if qryStanje.IsEmpty then Exit;

  OdabraniArtikalID := qryStanje.FieldByName('ID').AsInteger;
  Trenutno := qryStanje.FieldByName('TrenutnoStanje').AsInteger;

  UnosPartnera := InputBox('Otpremnica', 'Kome prodajete robu (Naziv Kupca):', 'Petar Petrović');
  if UnosPartnera = '' then Exit;

  UnosKolicine := InputBox('Otpremnica', 'Unesite količinu za prodaju:', '1');

  if TryStrToInt(UnosKolicine, Kolicina) and (Kolicina > 0) then
  begin
    if Kolicina > Trenutno then
    begin
      ShowMessage('Greška! Nemate dovoljno na stanju. Trenutno stanje je: ' + IntToStr(Trenutno));
      Exit;
    end;

    DM.IzvrsiUpit('INSERT INTO Dokumenti (TipDokumenta, BrojDokumenta, Datum, Partner_ID, ImePartnera) ' +
                  'VALUES (''OTPREMNICA'', ''OT-' + FormatDateTime('yymmddhhnnss', Now) + ''', DATE(''now''), 2, ''' + UnosPartnera + ''')');

    DokumentID := DM.Konekcija.ExecSQLScalar('SELECT last_insert_rowid()');

    DM.IzvrsiUpit('INSERT INTO StavkeDokumenta (Dokument_ID, Artikal_ID, Kolicina, UlazIzlaz) ' +
                  'VALUES (' + IntToStr(DokumentID) + ', ' + IntToStr(OdabraniArtikalID) + ', ' + IntToStr(Kolicina) + ', -1)');
    OsveziStanje;
  end;
end;

procedure TMainForm.btnStornirajClick(Sender: TObject);
var
  DokID: string;
begin
  if qryIstorija.IsEmpty then Exit;

  if Application.MessageBox('Da li ste sigurni da želite obrisati ovaj dokument?', 'Potvrda storniranja', MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    DokID := qryIstorija.FieldByName('DokumentID').AsString;
    DM.IzvrsiUpit('DELETE FROM StavkeDokumenta WHERE Dokument_ID = ' + DokID);
    DM.IzvrsiUpit('DELETE FROM Dokumenti WHERE ID = ' + DokID);
    OsveziStanje;
    ShowMessage('Dokument uspešno storniran! Stanje je osveženo.');
  end;
end;

procedure TMainForm.btnIzvozClick(Sender: TObject);
var
  F: TextFile;
  S: string;
begin
  if qryStanje.IsEmpty then Exit;

  AssignFile(F, ExtractFilePath(ParamStr(0)) + 'IzvestajZaliha.csv');
  Rewrite(F);
  Writeln(F, 'Sifra,Kategorija,Naziv,JM,Cena,TrenutnoStanje');

  qryStanje.DisableControls;
  qryStanje.First;
  while not qryStanje.Eof do
  begin
    S := qryStanje.FieldByName('Sifra').AsString + ',' +
         qryStanje.FieldByName('Kategorija').AsString + ',' +
         qryStanje.FieldByName('Naziv').AsString + ',' +
         qryStanje.FieldByName('JedinicaMere').AsString + ',' +
         qryStanje.FieldByName('Cena').AsString + ',' +
         qryStanje.FieldByName('TrenutnoStanje').AsString;
    Writeln(F, S);
    qryStanje.Next;
  end;

  qryStanje.First;
  qryStanje.EnableControls;
  CloseFile(F);
  ShowMessage('Izveštaj uspešno sačuvan kao IzvestajZaliha.csv u folderu aplikacije!');
end;

end.
