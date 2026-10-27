-- Lista XCC: un rând per utilizator, cu bifele, alegerile, notițele și etichetele.
-- Fiecare vede și modifică doar rândul lui (Row Level Security).

create table if not exists public.xcc_state (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  done       jsonb not null default '{}'::jsonb,
  picks      jsonb not null default '{}'::jsonb,
  notes      jsonb not null default '{}'::jsonb,
  labels     jsonb not null default '{}'::jsonb check (jsonb_typeof(labels) = 'object'),
  updated_at timestamptz not null default now()
);

-- pentru tabelele create înainte de etichete
alter table public.xcc_state
  add column if not exists labels jsonb not null default '{}'::jsonb;

alter table public.xcc_state enable row level security;

create policy "xcc: citesc doar randul meu"
  on public.xcc_state for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "xcc: creez doar randul meu"
  on public.xcc_state for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "xcc: modific doar randul meu"
  on public.xcc_state for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- fără login: niciun drept; cu login: doar ce folosește aplicația
revoke all on public.xcc_state from anon;
revoke delete, truncate, references, trigger on public.xcc_state from authenticated;
grant select, insert, update on public.xcc_state to authenticated;

-- ---------------------------------------------------------------------------
-- Date pregătite dinainte pentru un anumit email (de ex. ce ai deja bifat).
-- La prima intrare, aplicația apelează xcc_claim_seed() și primește rândul.
-- Schema "private" nu e expusă prin API; rândurile din xcc_seed se adaugă
-- direct în baza de date, nu din acest fișier (repo-ul e public).

create schema if not exists private;

create table if not exists private.xcc_seed (
  email      text primary key,
  done       jsonb not null default '{}'::jsonb,
  picks      jsonb not null default '{}'::jsonb,
  notes      jsonb not null default '{}'::jsonb,
  claimed_at timestamptz
);

create or replace function public.xcc_claim_seed()
returns setof public.xcc_state
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
  em  text := lower(coalesce(auth.jwt() ->> 'email', ''));
begin
  if uid is null or em = '' then
    return;
  end if;

  insert into public.xcc_state (user_id, done, picks, notes)
  select uid, s.done, s.picks, s.notes
  from private.xcc_seed s
  where lower(s.email) = em and s.claimed_at is null
  on conflict (user_id) do nothing;

  update private.xcc_seed set claimed_at = now()
  where lower(email) = em and claimed_at is null;

  return query select * from public.xcc_state where user_id = uid;
end;
$$;

revoke execute on function public.xcc_claim_seed() from public, anon;
grant execute on function public.xcc_claim_seed() to authenticated;
