-- Run once in your own Supabase project's SQL editor.
create table public.organizers(user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.organizers enable row level security;
create policy own_organizer_record on public.organizers for select to authenticated using(user_id=auth.uid());
create table public.registrations (
 id uuid primary key default gen_random_uuid(),
 created_at timestamptz not null default now(),
 name text not null check(length(trim(name)) between 1 and 80),
 age integer not null check(age between 8 and 70),
 city text not null check(length(trim(city)) between 1 and 60),
 phone text not null check(length(trim(phone)) between 1 and 24),
 height integer check(height between 120 and 240),
 style text not null check(length(style) between 1 and 80),
 social text check(length(social)<=80),
 highlights text check(highlights='' or (highlights ~* '^https://' and length(highlights)<=500)),
 consent boolean not null check(consent=true)
);
alter table public.registrations enable row level security;
create policy registration_submission on public.registrations for insert to anon,authenticated with check(consent=true);
create policy organizer_read on public.registrations for select to authenticated using(exists(select 1 from public.organizers where user_id=auth.uid()));
create table public.tournament(id integer primary key check(id=1),content jsonb not null);
alter table public.tournament enable row level security;
create policy public_tournament on public.tournament for select to anon,authenticated using(true);
create policy organizer_update on public.tournament for update to authenticated using(exists(select 1 from public.organizers where user_id=auth.uid())) with check(exists(select 1 from public.organizers where user_id=auth.uid()));
insert into public.tournament values(1,'{"date":"To be announced / يُعلن قريباً","venue":"To be announced / يُعلن قريباً","fee":"To be announced / يُعلن قريباً","results":[]}');
grant usage on schema public to anon,authenticated;
revoke all on public.registrations,public.organizers,public.tournament from anon,authenticated;
grant insert on public.registrations to anon,authenticated;
grant select on public.registrations,public.organizers to authenticated;
grant select on public.tournament to anon,authenticated;
grant update(content) on public.tournament to authenticated;
-- After creating your organizer user in Authentication, copy its actual UUID.
-- Replace YOUR_ACTUAL_USER_UUID below, then run that statement separately:
-- insert into public.organizers(user_id) values ('YOUR_ACTUAL_USER_UUID');
