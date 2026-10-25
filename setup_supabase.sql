-- =====================================================================
-- PIDgey · Banco de dados (Supabase / PostgreSQL 15+)
-- Usado por: PIDgey (público, só consulta). O público (anon) só chama consultar_pid().
-- Execute este arquivo inteiro no SQL Editor do Supabase, uma única vez (setup_supabase.sql).
-- ATENÇÃO: rode ANTES o setup_supabase.sql do PokéPOS, no mesmo projeto do Supabase:
-- a consulta lê a tabela bottons e usa a função pid_fmt(), criadas por ele.
-- Horários são guardados em UTC (timestamptz); o site exibe em America/Sao_Paulo.
-- =====================================================================

-- ---------- 0. Confere se o setup do PokéPOS já foi executado ----------
do $$
begin
  if to_regclass('public.bottons') is null
     or to_regprocedure('public.pid_fmt(bigint,smallint)') is null then
    raise exception 'Rode primeiro o setup_supabase.sql do PokéPOS neste mesmo projeto do Supabase.';
  end if;
end $$;

-- ---------- 1. PIDgey: consulta pública (a única coisa que o público pode fazer) ----------
-- Devolve só dados públicos de botton JÁ ENTREGUE (sem preço, sem Caixa). Roda com os direitos do dono.
create or replace function consultar_pid(p_pid text) returns json
language plpgsql stable security definer set search_path = public as $$
declare
  d text := regexp_replace(coalesce(p_pid, ''), '\D', '', 'g');
  r record;
begin
  if length(d) <> 11 then return null; end if;
  select b.folha, b.numero, b.arte, b.fabricado_em, b.entregue_em into r
    from bottons b
   where b.folha = substr(d, 1, 9)::bigint
     and b.numero = substr(d, 10, 2)::smallint
     and b.entregue_em is not null;
  if not found then return null; end if;
  return json_build_object(
    'pid',          pid_fmt(r.folha, r.numero),
    'lote',         (r.folha + 1)::text,
    'item',         (r.numero + 1)::text,
    'arte',         r.arte,
    'fabricado_em', to_char(r.fabricado_em at time zone 'America/Sao_Paulo', 'DD/MM/YYYY HH24:MI:SS'),
    'entregue_em',  to_char(r.entregue_em  at time zone 'America/Sao_Paulo', 'DD/MM/YYYY HH24:MI:SS')
  );
end $$;

-- ---------- 2. Permissões ----------
-- Só o necessário: o público (anon) executa consultar_pid() e mais nada.
revoke execute on function consultar_pid(text) from public, anon, authenticated;
grant  execute on function consultar_pid(text) to anon, authenticated;
