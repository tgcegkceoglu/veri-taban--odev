-- Ödev-1: Ürün Aktif mi? 

-- Amaç: Verilen ürünün id sine göre ürünün satışta olup olmadığını döndürür.
-- discontinued - ürün 0 ise satışta, 1 ise ürün satıştan kaldırılmıştır.
-- Kullanılan tablo:products(product_id,discontinued)
-- Parametreler:p_product_id
-- Dönüş Türü:boolean
create or replace function nw_is_product_active(p_product_id int)
returns boolean
language sql
as $$
select case
   when discontinued = 0 then true
   when discontinued = 1 then false
   else null
  end
 from products where product_id = p_product_id
$$

-- test --
select nw_is_product_active(2) as "Ürün Durumu"; -- Beklenen: false
select nw_is_product_active(3) as "Ürün Durumu"; -- Beklenen: true


-- Ödev-2: Tedarikçi Ürün Sayısı
-- Amaç: Verilen tedarikçi id sine göre, o tedarikçinin kaç ürünü olduğunu verir. 
-- Eğer hiç ürünü yoksa 0 döner.
-- Kullanılan tablo:products(supplier_id)
-- Parametreler:supplier_id
-- Dönüş Türü:int
create or replace function nw_supplier_product_count(p_supplier_id int)
returns int
language sql
as $$
  select coalesce(count(*),0) from products where supplier_id = p_supplier_id
$$


-- test --
select nw_supplier_product_count(8) as "Tedarikçi Ürün Sayısı"; -- Beklenen : 5
select nw_supplier_product_count(30) as "Tedarikçi Ürün Sayısı"; -- Beklenen : 0

-- Ödev-3: Müşterinin Yıllık Sipariş Adedi
-- Amaç: Bir müşterinin belirtilen yılda vermiş olduğu siparişlerin sayısını verir.
-- Kullanılan tablo:orders(customer_id,order_date)
-- Parametreler:p_customer_id, p_year
-- Dönüş Türü:int - müşteri yoksa 0 

create or replace function nw_customer_order_count(p_customer_id text, p_year int)
returns int
language sql
as $$
select coalesce(count(*),0) 
from orders where customer_id = p_customer_id and date_part('year',order_date) = p_year;
$$

-- test --
SELECT nw_customer_order_count('ALFKI', 1997) as "ALFKI 1997 yılındaki sipariş sayısı"; -- Beklenen sonuç: 1997 ve 1998 de 3 adet siparişi var.
SELECT nw_customer_order_count('HANAR', 1996) as "HANAR 1996 yılındaki sipariş sayısı"; -- Beklenen sonuç: 1996 da 2 adet siparişi var.


-- Ödev-4: Müşterinin Son Sipariş Tarihi 
-- Amaç: Müşterinin en son sipariş ettiği tarihi döndürmektedir.
-- Kullanılan tablo:orders(customer_id,order_date)
-- Parametreler:p_customer_id
-- Dönüş Türü:date - sipariş yoksa null

create or replace function nw_customer_last_order_date(p_customer_id text)
returns date
language sql

as $$
select max(o.order_date) from orders o where o.customer_id = p_customer_id
$$

-- test --
select nw_customer_last_order_date('TOMSP') as "TOMSP son sipariş tarihi"; -- Beklenen sonuç: 1998-03-23
select nw_customer_last_order_date('LOL') as "LOL son sipariş tarihi"; -- Beklenen sonuç: null



-- Ödev-5: Tek Siparişin Brüt Değeri
-- Amaç:  Bir siparişin toplam tutarı (indirim hesaba katılmış).
-- Kullanılan tablo:order_details(unit_price,quantity,discount)
-- Parametreler:p_order_id 
-- Dönüş Türü: numeric(12,2)

create or replace function  nw_order_gross_value(p_order_id int)
returns numeric(12,2)
language sql
as $$
  select sum(od.unit_price * od.quantity * (1-od.discount))::numeric(12,2)
  from order_details od 
  where od.order_id = p_order_id
$$

-- test --
SELECT nw_order_gross_value(10248); -- beklenen sonuç = 440
SELECT nw_order_gross_value(10250); -- beklenen sonuç = 1,552.6

-- Ödev-6: Ürünün Tarih Aralığı Geliri
-- Amaç: Ürünün belirli tarih aralığındaki toplam gelirini hesaplar.
-- Kullanılan tablo:order_details(unit_price,quantity,discount) - orders(order_id)
-- Parametreler:p_product_id, p_start, p_end
-- Dönüş Türü: numeric(12,2) - Sonuç yoksa 0

create or replace function nw_product_revenue(p_product_id int, p_start date DEFAULT '1900-01-01', p_end date DEFAULT '9999-12-31')
returns numeric(12,2)
language sql
as $$
  select coalesce(sum(od.unit_price * od.quantity * (1-od.discount))::numeric(12,2),0.00) 
  from orders o inner join order_details od on o.order_id = od.order_id
  where od.product_id = p_product_id and o.order_date between p_start and p_end
$$

-- test --
SELECT nw_product_revenue(14, '1996-07-10', '1996-12-10') as "Ürün Geliri";  -- beklenen sonuç: 632.4
SELECT nw_product_revenue(65, '1996-07-10', '1999-12-10') as "Ürün Geliri";  -- beklenen sonuç: 13,319.69


-- Ödev-7: Reorder Önerisi
-- Yapamadım--






