-- DEMOSTRACIÓN: directorio público, sin autenticación.
-- NO USAR con datos personales reales sin implementar control de acceso,
-- moderación, política de privacidad y mecanismos de eliminación.
create extension if not exists pgcrypto;
create table if not exists public.participants (
 id uuid primary key default gen_random_uuid(),
 created_at timestamptz not null default now(),
 nombre text not null, pais text not null, telefono text not null,
 correo text not null, institucion text not null,
 cargo text not null, profesion text not null, intereses text not null,
 photo_url text, pdf_url text
);
alter table public.participants enable row level security;
create policy "Directory public read" on public.participants for select to anon using (true);
create policy "Public registration" on public.participants for insert to anon with check (
 length(nombre) between 1 and 130 and length(pais) between 1 and 90
 and length(correo) between 3 and 150
);
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('cdac-records','cdac-records',true,10485760,array['application/pdf','image/jpeg'])
on conflict (id) do nothing;
create policy "Public profile files read" on storage.objects for select to anon
 using (bucket_id='cdac-records');
create policy "Public profile files upload" on storage.objects for insert to anon
 with check (bucket_id='cdac-records' and (storage.extension(name) in ('pdf','jpg')));
