unit UDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Konekcija: TFDConnection;
    procedure IzvrsiUpit(Upit: string);
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.IzvrsiUpit(Upit: string);
begin
  Konekcija.ExecSQL(Upit);
end;

procedure TDM.DataModuleCreate(Sender: TObject);
var
  PutanjaDoBaze: string;
begin
  // Pravimo novu Konekciju POTPUNO KROZ KOD (bez prevlačenja!)
  Konekcija := TFDConnection.Create(Self);

  PutanjaDoBaze := ExtractFilePath(ParamStr(0)) + 'is_zalihe_pro.db';

  Konekcija.Params.Clear;
  Konekcija.Params.Add('DriverID=SQLite');
  Konekcija.Params.Add('Database=' + PutanjaDoBaze);
  Konekcija.Params.Add('OpenMode=CreateUTF8');
  Konekcija.LoginPrompt := False;
  Konekcija.Connected := True;

  // 1. Tabela Artikli (Šifarnik robe - bez količine!)
  IzvrsiUpit(
    'CREATE TABLE IF NOT EXISTS Artikli (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'Sifra VARCHAR(20) UNIQUE, ' +
    'Naziv VARCHAR(100), ' +
    'JedinicaMere VARCHAR(10), ' +
    'Cena REAL)'
  );

  // 2. Tabela Partneri (Dobavljači / Kupci)
  IzvrsiUpit(
    'CREATE TABLE IF NOT EXISTS Partneri (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'Naziv VARCHAR(100), ' +
    'PIB VARCHAR(20), ' +
    'Adresa VARCHAR(100))'
  );

  // 3. Tabela Dokumenti (Zaglavlje Prijemnice/Otpremnice - OVO PROFESOR TRAŽI)
  IzvrsiUpit(
    'CREATE TABLE IF NOT EXISTS Dokumenti (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'TipDokumenta VARCHAR(20), ' + // Npr. "PRIJEMNICA" ili "OTPREMNICA"
    'BrojDokumenta VARCHAR(50), ' +
    'Datum DATE, ' +
    'Partner_ID INTEGER, ' +
    'FOREIGN KEY(Partner_ID) REFERENCES Partneri(ID))'
  );

  // 4. Tabela Stavke (Šta se tačno nalazi na tom dokumentu)
  IzvrsiUpit(
    'CREATE TABLE IF NOT EXISTS StavkeDokumenta (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'Dokument_ID INTEGER, ' +
    'Artikal_ID INTEGER, ' +
    'Kolicina INTEGER, ' +
    'UlazIzlaz INTEGER, ' + // 1 za ulaz, -1 za izlaz
    'FOREIGN KEY(Dokument_ID) REFERENCES Dokumenti(ID), ' +
    'FOREIGN KEY(Artikal_ID) REFERENCES Artikli(ID))'
  );
  // UBACIVANJE POČETNIH PODATAKA (Ako je baza prazna)
  IzvrsiUpit('INSERT OR IGNORE INTO Partneri (ID, Naziv, PIB) VALUES (1, ''Nike Srbija d.o.o.'', ''100000001'')');
  IzvrsiUpit('INSERT OR IGNORE INTO Partneri (ID, Naziv, PIB) VALUES (2, ''Adidas Balkan'', ''100000002'')');

  IzvrsiUpit('INSERT OR IGNORE INTO Artikli (ID, Sifra, Naziv, JedinicaMere, Cena) VALUES (1, ''PAT01'', ''Nike Air Max'', ''kom'', 15000)');
  IzvrsiUpit('INSERT OR IGNORE INTO Artikli (ID, Sifra, Naziv, JedinicaMere, Cena) VALUES (2, ''PAT02'', ''Adidas Superstar'', ''kom'', 12000)');
end;

end.
