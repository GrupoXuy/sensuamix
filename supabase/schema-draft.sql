-- SENSUAMIX — draft schema for supplier-fulfilled commerce
-- DESIGN ONLY. NOT APPLIED TO ANY DATABASE.
-- No owned stock: availability is tracked per supplier offer with timestamps.

create table if not exists public.customer_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  legal_name text,
  trade_name text not null,
  contact_name text,
  contact_email text,
  contact_phone text,
  status text not null default 'pending'
    check (status in ('pending','under_review','approved','suspended')),
  ships_direct_to_customer boolean not null default false,
  discreet_outer_packaging boolean not null default false,
  default_dispatch_days integer check (default_dispatch_days is null or default_dispatch_days >= 0),
  terms_url text,
  internal_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  category text not null check (category in ('lingerie','bem-estar')),
  short_description text,
  description text,
  image_url text,
  age_restricted boolean not null default true,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.supplier_offers (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references public.suppliers(id),
  product_id uuid not null references public.products(id),
  supplier_sku text,
  availability_status text not null default 'unknown'
    check (availability_status in ('unknown','in_stock','low_stock','out_of_stock','temporarily_unavailable')),
  supplier_cost numeric(12,2) check (supplier_cost is null or supplier_cost >= 0),
  customer_price numeric(12,2) check (customer_price is null or customer_price >= 0),
  currency_code char(3) check (currency_code is null or currency_code ~ '^[A-Z]{3}$'),
  ready_to_ship boolean not null default false,
  direct_fulfillment_available boolean not null default false,
  discreet_packaging_available boolean not null default false,
  dispatch_days integer check (dispatch_days is null or dispatch_days >= 0),
  checked_at timestamptz,
  valid_until timestamptz,
  is_active boolean not null default true,
  internal_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint offer_validity check (valid_until is null or checked_at is null or valid_until >= checked_at)
);
create index if not exists supplier_offers_product_idx on public.supplier_offers(product_id,is_active);
create index if not exists supplier_offers_supplier_idx on public.supplier_offers(supplier_id,is_active);
create index if not exists supplier_offers_availability_idx on public.supplier_offers(availability_status,checked_at desc);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  customer_id uuid references public.customer_profiles(id),
  status text not null default 'awaiting_supplier_confirmation'
    check (status in ('awaiting_supplier_confirmation','quote_ready','awaiting_customer_approval','awaiting_payment','paid','supplier_processing','dispatched','delivered','cancelled','expired','refunded')),
  customer_name text not null,
  customer_email text not null,
  customer_phone text not null,
  delivery_country text,
  delivery_region text,
  delivery_city text,
  delivery_postal_code text,
  delivery_address_line text,
  delivery_address_extra text,
  currency_code char(3),
  items_subtotal numeric(12,2),
  shipping_total numeric(12,2),
  order_total numeric(12,2),
  supplier_confirmed_at timestamptz,
  quote_expires_at timestamptz,
  customer_approved_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint order_currency check (currency_code is null or currency_code ~ '^[A-Z]{3}$'),
  constraint order_totals check (
    (items_subtotal is null or items_subtotal >= 0) and
    (shipping_total is null or shipping_total >= 0) and
    (order_total is null or order_total >= 0)
  )
);
create index if not exists orders_customer_idx on public.orders(customer_id,created_at desc);
create index if not exists orders_status_idx on public.orders(status,created_at desc);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id),
  supplier_offer_id uuid references public.supplier_offers(id),
  product_name_snapshot text not null,
  supplier_sku_snapshot text,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  currency_code char(3) not null check (currency_code ~ '^[A-Z]{3}$'),
  created_at timestamptz not null default now()
);
create index if not exists order_items_order_idx on public.order_items(order_id);

create table if not exists public.supplier_fulfillments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  supplier_id uuid not null references public.suppliers(id),
  status text not null default 'awaiting_supplier'
    check (status in ('awaiting_supplier','accepted','preparing','dispatched','delivered','failed','cancelled')),
  supplier_order_reference text,
  carrier text,
  tracking_code text,
  tracking_url text,
  discreet_packaging_confirmed boolean not null default false,
  accepted_at timestamptz,
  dispatched_at timestamptz,
  delivered_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists supplier_fulfillments_order_idx on public.supplier_fulfillments(order_id);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  provider text not null,
  provider_reference text,
  status text not null default 'pending'
    check (status in ('pending','authorized','paid','failed','cancelled','refunded','chargeback')),
  amount numeric(12,2) not null check (amount >= 0),
  currency_code char(3) not null check (currency_code ~ '^[A-Z]{3}$'),
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  event_type text not null,
  description text not null,
  customer_visible boolean not null default false,
  actor_user_id uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create index if not exists order_events_order_idx on public.order_events(order_id,created_at);

-- Enable RLS for every public table.
alter table public.customer_profiles enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.supplier_offers enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.supplier_fulfillments enable row level security;
alter table public.payments enable row level security;
alter table public.order_events enable row level security;

grant select on public.products to anon,authenticated;
grant select,insert,update,delete on
  public.customer_profiles,public.suppliers,public.supplier_offers,public.products,
  public.orders,public.order_items,public.supplier_fulfillments,public.payments,public.order_events
to authenticated;

-- Public catalog is limited to products explicitly published by an administrator.
create policy "Public can read published catalog" on public.products
  for select to anon,authenticated using (is_published = true and age_restricted = true);

-- Admin uses trusted app_metadata claim; never authorize with user-editable user_metadata.
create policy "Admins manage products" on public.products for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Customers read own profile" on public.customer_profiles for select to authenticated
  using ((select auth.uid()) = id);
create policy "Admins manage customer profiles" on public.customer_profiles for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Admins manage suppliers" on public.suppliers for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Admins manage supplier offers" on public.supplier_offers for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Admins manage orders" on public.orders for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Customers read own orders" on public.orders for select to authenticated
  using ((select auth.uid()) = customer_id);
create policy "Admins manage order items" on public.order_items for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Customers read own order items" on public.order_items for select to authenticated
  using (exists(select 1 from public.orders o where o.id = order_id and o.customer_id = (select auth.uid())));
create policy "Admins manage fulfillments" on public.supplier_fulfillments for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Customers read own fulfillments" on public.supplier_fulfillments for select to authenticated
  using (exists(select 1 from public.orders o where o.id = order_id and o.customer_id = (select auth.uid())));
create policy "Admins manage payments" on public.payments for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Customers read own payments" on public.payments for select to authenticated
  using (exists(select 1 from public.orders o where o.id = order_id and o.customer_id = (select auth.uid())));
create policy "Admins manage order events" on public.order_events for all to authenticated
  using ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin')
  with check ((select auth.jwt() -> 'app_metadata' ->> 'role') = 'sensuamix_admin');
create policy "Customers read visible order events" on public.order_events for select to authenticated
  using (customer_visible = true and exists(select 1 from public.orders o where o.id = order_id and o.customer_id = (select auth.uid())));

-- No public customer INSERT policy exists for orders, items or payments.
-- Future checkout must create records server-side after supplier confirmation and customer approval.
-- Never expose service_role/secret keys in frontend code.
