-- ============================================================================
-- Mise Betriebs-OS — zentrale Kunden-Datenbank (Schritt 1: Schema-Entwurf)
-- Ziel: eine gemeinsame Datenquelle für Finanzen, Sales und Marketing.
-- HR/Personal bewusst NICHT angebunden (andere Datenkategorie, DSGVO).
-- Zielplattform: Supabase (Postgres) — RLS-Policies siehe db/policies.sql
-- ============================================================================

-- ---------- Enums ----------
create type kunde_typ as enum ('kunde', 'lieferant');
create type kunde_status as enum ('stammkunde', 'neukunde', 'inaktiv');
create type rechnung_status as enum ('entwurf', 'offen', 'bezahlt', 'ueberfaellig');
create type vertrag_status as enum ('entwurf', 'versendet', 'unterschrieben', 'aktiv', 'beendet');
create type deal_stage as enum ('lead', 'kontaktiert', 'angebot', 'verhandlung', 'gewonnen', 'verloren');
create type interaktion_kanal as enum ('anruf', 'email', 'meeting', 'notiz', 'social');
create type consent_kanal as enum ('email', 'telefon', 'post', 'sms');

-- ---------- Kunden (Kern-Stammdaten, von allen Agenten genutzt) ----------
create table kunden (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  typ             kunde_typ not null default 'kunde',
  status          kunde_status not null default 'neukunde',
  adresse         text,
  plz             text,
  ort             text,
  ust_id          text,
  steuernummer    text,
  iban            text,
  bic             text,
  email           text,
  telefon         text,
  branche         text,
  notiz           text,
  erstellt_von    text,                 -- z.B. 'sales-agent', 'finanz-agent'
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ---------- Kontaktpersonen je Kunde (für Sales/Marketing) ----------
create table kontaktpersonen (
  id           uuid primary key default gen_random_uuid(),
  kunde_id     uuid not null references kunden(id) on delete cascade,
  name         text not null,
  rolle        text,                    -- z.B. 'Einkauf', 'Geschäftsführung'
  email        text,
  telefon      text,
  ist_hauptkontakt boolean not null default false,
  created_at   timestamptz not null default now()
);

-- ---------- Vertragsvorlagen (Merge-Feld-Templates) ----------
create table vertrag_vorlagen (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,           -- z.B. 'Catering-Rahmenvertrag'
  beschreibung text,
  dokument_url text,                    -- optionale Ablage einer .docx-Vorlage
  platzhalter  jsonb not null default '[]', -- ['kunde_name','ust_id',...]
  inhalt       text,                    -- Vertragstext mit {{platzhalter}} für die Merge-Vorschau/PDF
  created_at   timestamptz not null default now()
);

-- ---------- Verträge ----------
create table vertraege (
  id            uuid primary key default gen_random_uuid(),
  kunde_id      uuid not null references kunden(id) on delete restrict,
  vorlage_id    uuid references vertrag_vorlagen(id),
  titel         text not null,
  status        vertrag_status not null default 'entwurf',
  gueltig_von   date,
  gueltig_bis   date,
  wert          numeric(12,2),
  dokument_url  text,                   -- generiertes/unterschriebenes Dokument
  erstellt_von  text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ---------- Rechnungen (Finanz-Agent) ----------
create table rechnungen (
  id             uuid primary key default gen_random_uuid(),
  kunde_id       uuid not null references kunden(id) on delete restrict,
  nummer         text not null unique,
  status         rechnung_status not null default 'entwurf',
  datum          date not null,
  leistungsdatum date,
  faellig_am     date,
  positionen     jsonb not null default '[]', -- [{desc,qty,unit,price,vat}]
  netto          numeric(12,2),
  ust_betrag     numeric(12,2),
  brutto         numeric(12,2),
  notiz          text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- ---------- CRM: Verkaufschancen (Sales-Agent) ----------
create table deals (
  id           uuid primary key default gen_random_uuid(),
  kunde_id     uuid not null references kunden(id) on delete cascade,
  titel        text not null,
  stage        deal_stage not null default 'lead',
  wert         numeric(12,2),
  wahrscheinlichkeit smallint check (wahrscheinlichkeit between 0 and 100),
  erwarteter_abschluss date,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- ---------- CRM: Interaktionen/Aktivitäten (Sales + Marketing) ----------
create table interaktionen (
  id           uuid primary key default gen_random_uuid(),
  kunde_id     uuid not null references kunden(id) on delete cascade,
  agent        text not null,           -- 'sales-agent' | 'marketing-agent' | 'finanz-agent'
  kanal        interaktion_kanal not null,
  betreff      text,
  notiz        text,
  datum        timestamptz not null default now(),
  created_at   timestamptz not null default now()
);

-- ---------- Marketing-Einwilligung (DSGVO-Pflicht) ----------
create table marketing_consent (
  id           uuid primary key default gen_random_uuid(),
  kunde_id     uuid not null references kunden(id) on delete cascade,
  kanal        consent_kanal not null,
  opt_in       boolean not null default false,
  quelle       text,                    -- z.B. 'Newsletter-Formular', 'Vertrag'
  geaendert_am timestamptz not null default now(),
  unique (kunde_id, kanal)
);

-- ---------- Indizes ----------
create index idx_kontaktpersonen_kunde on kontaktpersonen(kunde_id);
create index idx_vertraege_kunde on vertraege(kunde_id);
create index idx_rechnungen_kunde on rechnungen(kunde_id);
create index idx_deals_kunde on deals(kunde_id);
create index idx_interaktionen_kunde on interaktionen(kunde_id);
create index idx_interaktionen_agent on interaktionen(agent);

-- ---------- updated_at automatisch pflegen ----------
create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_kunden_updated before update on kunden
  for each row execute function set_updated_at();
create trigger trg_vertraege_updated before update on vertraege
  for each row execute function set_updated_at();
create trigger trg_rechnungen_updated before update on rechnungen
  for each row execute function set_updated_at();
create trigger trg_deals_updated before update on deals
  for each row execute function set_updated_at();
