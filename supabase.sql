-- Lista XCC: un rând per utilizator, cu bifele, alegerile și notițele.
-- Fiecare vede și modifică doar rândul lui (Row Level Security).

create table if not exists public.xcc_state (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  done       jsonb not null default '{}'::jsonb,
  picks      jsonb not null default '{}'::jsonb,
  notes      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

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
