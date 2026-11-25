-- SensuaMix: admin-only financial records for manual sales and operating expenses.
-- Apply this migration to the project's Supabase database before using Financeiro.

create table if not exists public.cash_manual_sales (
  id uuid primary key default gen_random_uuid(),
  product_name text not null,
  order_reference text,
  quantity integer not null default 1 check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  total_amount numeric(12,2) not null check (total_amount > 0),
  currency_code char(3) not null default 'BRL' check (currency_code ~ '^[A-Z]{3}$'),
  payment_method text not null,
  sale_date date not null default current_date,
  status text not null default 'paid' check (status in ('paid','refunded')),
  notes text,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists cash_manual_sales_date_idx
  on public.cash_manual_sales(sale_date desc);
create index if not exists cash_manual_sales_status_date_idx
  on public.cash_manual_sales(status,sale_date desc);

create table if not exists public.cash_expenses (
  id uuid primary key default gen_random_uuid(),
  description text not null,
  category text not null,
  amount numeric(12,2) not null check (amount > 0),
  currency_code char(3) not null default 'BRL' check (currency_code ~ '^[A-Z]{3}$'),
  expense_date date not null default current_date,
  payment_method text not null,
  status text not null default 'paid' check (status in ('paid','pending')),
  notes text,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists cash_expenses_date_idx
  on public.cash_expenses(expense_date desc);
create index if not exists cash_expenses_status_date_idx
  on public.cash_expenses(status,expense_date desc);

alter table public.cash_manual_sales enable row level security;
alter table public.cash_expenses enable row level security;

drop policy if exists "SensuaMix admins manage manual sales" on public.cash_manual_sales;
create policy "SensuaMix admins manage manual sales"
  on public.cash_manual_sales for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');

drop policy if exists "SensuaMix admins manage expenses" on public.cash_expenses;
create policy "SensuaMix admins manage expenses"
  on public.cash_expenses for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');

grant select, insert, update, delete on public.cash_manual_sales to authenticated;
grant select, insert, update, delete on public.cash_expenses to authenticated;
