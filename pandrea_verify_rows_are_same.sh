mariadb -ABNe "select concat('On host ',@@hostname,': There are ',count(*),' rows on pandrea.tt_sold_tickets.') from pandrea.tt_sold_tickets;"
mariadb -usqluser -ppassword -h pan1.edw.ee -ABNe "select concat('On host ',@@hostname,': There are ',count(*),' rows on pandrea.tt_sold_tickets.') from pandrea.tt_sold_tickets;"

