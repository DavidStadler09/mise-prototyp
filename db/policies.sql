-- ============================================================================
-- Row-Level-Security — tatsächlich eingespielter Stand (Interimsphase)
-- ============================================================================
-- Es gibt noch KEINE echte Agenten-Authentifizierung (kein Supabase Auth,
-- alle Module nutzen denselben Publishable-Key im Browser). Eine Trennung
-- "Marketing darf keine Rechnungen sehen" ist deshalb auf DB-Ebene aktuell
-- nicht durchsetzbar (auth.jwt() liefert keinen 'agent'-Claim).
--
-- Daher: RLS ist aktiv, mit Policies, die das heutige tatsächliche Verhalten
-- abbilden (Browser-Client darf lesen/schreiben, kein Löschen). Sensible
-- Finanzfelder sind unabhängig davon per Column-Grant vor dem Browser
-- versteckt — das ist schon jetzt wirksam.
--
-- Sobald echte Logins pro Agent existieren, hier auf rollenbasierte Policies
-- umstellen (z.B. auth.jwt() ->> 'agent' oder eigene Supabase-Auth-Rollen).
-- ============================================================================

alter table kunden enable row level security;
alter table kontaktpersonen enable row level security;
alter table vertrag_vorlagen enable row level security;
alter table vertraege enable row level security;
alter table rechnungen enable row level security;
alter table deals enable row level security;
alter table interaktionen enable row level security;
alter table marketing_consent enable row level security;

create policy "app_select_kunden" on kunden for select using (true);
create policy "app_insert_kunden" on kunden for insert with check (true);
create policy "app_update_kunden" on kunden for update using (true);

create policy "app_select_kontaktpersonen" on kontaktpersonen for select using (true);
create policy "app_insert_kontaktpersonen" on kontaktpersonen for insert with check (true);
create policy "app_update_kontaktpersonen" on kontaktpersonen for update using (true);

create policy "app_select_vertrag_vorlagen" on vertrag_vorlagen for select using (true);
create policy "app_insert_vertrag_vorlagen" on vertrag_vorlagen for insert with check (true);
create policy "app_update_vertrag_vorlagen" on vertrag_vorlagen for update using (true);

create policy "app_select_vertraege" on vertraege for select using (true);
create policy "app_insert_vertraege" on vertraege for insert with check (true);
create policy "app_update_vertraege" on vertraege for update using (true);

create policy "app_select_rechnungen" on rechnungen for select using (true);
create policy "app_insert_rechnungen" on rechnungen for insert with check (true);
create policy "app_update_rechnungen" on rechnungen for update using (true);

create policy "app_select_deals" on deals for select using (true);
create policy "app_insert_deals" on deals for insert with check (true);
create policy "app_update_deals" on deals for update using (true);

create policy "app_select_interaktionen" on interaktionen for select using (true);
create policy "app_insert_interaktionen" on interaktionen for insert with check (true);
create policy "app_update_interaktionen" on interaktionen for update using (true);

create policy "app_select_marketing_consent" on marketing_consent for select using (true);
create policy "app_insert_marketing_consent" on marketing_consent for insert with check (true);
create policy "app_update_marketing_consent" on marketing_consent for update using (true);

-- Sensible Finanzfelder nie an den Browser-Client ausliefern, unabhängig vom Modul
-- (Supabase vergibt SELECT sonst tabellenweit — deshalb erst entziehen, dann
-- gezielt für die unkritischen Spalten neu vergeben).
revoke select on kunden from anon, authenticated;
grant select (id, name, typ, status, adresse, plz, ort, email, telefon, branche, notiz, ust_id, erstellt_von, created_at, updated_at)
  on kunden to anon, authenticated;
-- iban, bic, steuernummer bleiben nur für postgres/service_role lesbar.
