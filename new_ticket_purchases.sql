-- NEW TICKETS PURCHASED by Edward Stoever
use pandrea;
delimiter //
begin not atomic
declare qty,cust,evnt,start_set,fxfset,already_sold,tix,prchs,brcd integer;
declare paym decimal(10,2);
FOR ii IN 0..30
DO 


-- declare qty,cust,evnt,start_set,fxfset,already_sold,paym,tix,prchs,brcd integer;
set qty= cast(f_random_enum('1,2,2,2,2,2,2,2,3,3,3,3,4,4,4,5,5,5,6') as integer);
set cust = f_random_integer(900000000,902143423);
set evnt = f_random_integer(3,12004);
set brcd = f_random_boolean(1,0,90);
select abs(count(*)-10) into fxfset
from tt_events e 
inner join tt_venues v on (e.event_venue_id = v.venue_id)
inner join tt_venue_seats s on (v.venue_id =s.venue_id)
where e.event_id=evnt;

set fxfset=f_random_integer(0,fxfset);
-- do sleep(10);
drop temporary table if exists my_selected_tix;
create temporary table my_selected_tix as
select e.event_id,(e.event_base_price+s.venue_seat_base_price) as ticket_price,s.venue_seat_id,s.venue_seat_common_id
from tt_events e 
inner join tt_venues v on (e.event_venue_id = v.venue_id)
inner join tt_venue_seats s on (v.venue_id =s.venue_id)
where e.event_id=evnt order by s.venue_seat_id
limit qty offset fxfset;
-- do sleep(10);
select count(*) into already_sold from tt_sold_tickets t inner join my_selected_tix m on (t.event_id=m.event_id and t.venue_seat_id=m.venue_seat_id);

if already_sold = 0 THEN
  select sum(ticket_price),count(*) into paym,tix from my_selected_tix;
start transaction;
  insert into tt_purchases (customer_id,purchase_datetime,payment_method,payment_amount,quantity_tickets)
  VALUES
  (cust,now(),f_random_enum('VISA,MASTERCARD,AMEX,CASH,VISA,VISA,VISA,MASTERCARD,AMEX'),paym,tix);

  set prchs = LAST_INSERT_ID();

  insert into tt_sold_tickets(ticket_price,event_id,venue_seat_id,venue_seat_common_id,customer_id,purchase_id,barcode_printed)
  SELECT a.ticket_price, a.event_id, a.venue_seat_id, b.venue_seat_common_id, cust, prchs, brcd from my_selected_tix a
  inner join tt_venue_seats b on (a.venue_seat_id=b.venue_seat_id);
commit;

ELSE
 insert into tt_already_sold_tickets select event_id,ticket_price,venue_seat_id,venue_seat_common_id,now() from my_selected_tix;
end if;

do sleep(2);
end for;

end;
//
delimiter ;

