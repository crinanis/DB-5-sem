-- Создайте процедуру, которая выводит список заказов 
-- и их итоговую стоимость для определенного покупателя. 
-- Параметр – наименование покупателя. 
-- Обработайте возможные ошибки.

create or replace procedure GetOrdersAndSumByCustomer(customer_id in varchar2)
as
    cursor cus is 
        select * 
        from ORDERS ord
        where ord.CUST = customer_id;
     
    price_sum number := 0;
begin
    
    for q_order in cus
        loop
            dbms_output.put_line(q_order.ORDER_NUM || ' ' || q_order.ORDER_DATE || ' ' || q_order.AMOUNT);
            price_sum := price_sum + q_order.AMOUNT;
        end loop;
        
        dbms_output.put_line('price sum: ' || price_sum);
        
    exception 
        when NO_DATA_FOUND then
            dbms_output.put_line('no data found');
        when others then
            dbms_output.put_line(sqlerrm);
end;


begin
    GetOrdersAndSumByCustomer(2108);
end;

-- Создайте функцию, которая подсчитывает количество заказов покупателя 
-- за определенный период. 
-- Параметры – покупатель, дата начала периода, дата окончания периода.

-- можно ещё адекватную дату поставить
-- ALTER SESSION SET nls_date_format='yyyy-mm-dd';

create or replace function GetAmountOrdersByCustAndDate(cust_id in number, start_date in varchar2, end_date in varchar2) 
return number
as
    counter number := 0;
begin
    select COUNT(*) into counter
    from orders ord
    where ord.CUST = cust_id and ord.ORDER_DATE between start_date and end_date;
    
    return counter;
end;


select GetAmountOrdersByCustAndDate(2111, '10-JAN-08', '19-FEB-08') from dual;

-- Создайте процедуру, которая выводит список всех товаров, приобретенных покупателем, 
-- с указанием суммы продаж по возрастанию. 
-- Параметр – наименование покупателя. Обработайте возможные ошибки.

create or replace procedure GetProductsByCustomerOrderByAmount(customer_id in number)
as

    cursor cur is 
        select pr.description, sum(ord.amount) as sum from products pr
        join orders ord
            on pr.product_id = ord.product
        group by pr.description, ord.cust
        having ord.cust = customer_id
        order by sum(ord.amount) desc;

begin

    for q_cur in cur
        loop
            dbms_output.put_line(q_cur.description || ' ' || q_cur.sum);
        end loop;

    exception when others then
        dbms_output.put_line(sqlerrm);
end;

begin 
    GetProductsByCustomerOrderByAmount(2111);
end;


-- Создайте функцию, которая добавляет покупателя в таблицу Customers, 
-- и возвращает код добавленного покупателя или -1 в случае ошибки. 
-- Параметры соответствуют столбцам таблицы, кроме кода покупателя, который задается при помощи последовательности.


-- Про последовательность прикола не понял, т.к. ещё не существует изначально, ну а так можно:
-- create sequence cust_num_seq start with 10000;
-- cust_num_seq.NEXTVAL;


create or replace function AddCustomer(company_name in varchar2, cust_rep_id in number, credit_limit_num in number)
return number
as
    cust_id number;
begin
    insert into CUSTOMERS(COMPANY, CUST_REP, CREDIT_LIMIT)
    values 
        (company_name, cust_rep_id, credit_limit_num)
    returning cust_num into cust_id;
    
    exception when others then
        DBMS_OUTPUT.PUT_LINE(sqlerrm);
        return -1;
end;

declare
    retval number;
begin
    retval := AddCustomer('test', 109, 50000);
    dbms_output.put_line(retval);
end;


-- Создайте процедуру, которая выводит список покупателей,
-- в порядке убывания общей стоимости заказов. 
-- Параметры – дата начала периода, дата окончания периода. 
-- Обработайте возможные ошибки.

-- можно ещё адекватную дату поставить
-- ALTER SESSION SET nls_date_format='yyyy-mm-dd';


create or replace procedure GetCust(start_date varchar2, end_date varchar2)
as

    cursor cur is
        select  cust.COMPANY, sum(ord.AMOUNT) as price_sum 
        from customers cust
        join orders ord
            on ord.CUST = cust.CUST_NUM and ord.order_date between '04-JAN-07' and '02-MAR-08'
        group by ord.cust, cust.COMPANY
        order by sum(ord.AMOUNT) desc;

begin
    
    for qcur in cur
        loop
            dbms_output.put_line(qcur.COMPANY || ' ' || qcur.price_sum);
        end loop;
    
    exception when others then
        dbms_output.put_line(sqlerrm);

end;


begin
    GetCust('04-JAN-07', '02-MAR-08');
end;


-- Создайте функцию, которая подсчитывает количество заказанных товаров за определенный период. 
-- Параметры – дата начала периода, дата окончания периода.

-- можно ещё адекватную дату поставить
-- ALTER SESSION SET nls_date_format='yyyy-mm-dd';


create or replace function GetProductAmount(start_date varchar2, end_date varchar2) 
return number
as
    counter number:= 0;
begin

    select sum(ord.QTY) into counter
    from orders ord
    where ord.order_date between start_date and end_date;


    return counter;
end;

    
select GetProductAmount('04-JAN-07', '02-MAR-08') from dual;

-- Создайте процедуру, которая выводит список покупателей, 
-- у которых есть заказы в этом временном периоде. 
-- Параметры – дата начала периода, дата окончания периода. 
-- Обработайте возможные ошибки

-- можно ещё адекватную дату поставить
-- ALTER SESSION SET nls_date_format='yyyy-mm-dd';

create or replace procedure GetCustByDate(start_date varchar2, end_date varchar2)
as

    cursor cur is
        select cust.CUST_NUM, cust.COMPANY from CUSTOMERS cust
        join ORDERS ord
            on cust.CUST_NUM = ord.CUST and ord.ORDER_DATE between start_date and end_date
        group by cust.CUST_NUM, cust.COMPANY;
begin

    for qcur in cur
        loop
            dbms_output.put_line(qcur.COMPANY);
        end loop;


    exception when others then
        dbms_output.put_line(sqlerrm);

end;

begin
    GetCustByDate('04-JAN-07', '02-MAR-08');
end;


-- Создайте функцию, которая подсчитывает количество покупателей определенного товара.
-- Параметры – наименование товара.


create or replace function GetAmountCustByProduct(product_id in varchar2) return number
as
    counter number := 0;
begin
    select COUNT(distinct(ord.CUST)) into counter
    from  orders ord
    where ord.PRODUCT = product_id;
    
    return counter;
end;

select GetAmountCustByProduct('41004') from dual;

-- Создайте процедуру, которая увеличивает на 10% стоимость определенного товара. 
-- Параметр – наименование товара. 
-- Обработайте возможные ошибки


create or replace procedure Add10PercToProductPrice(product varchar2)
as
begin

    update PRODUCTS
    set PRICE = PRICE + PRICE*0.1
    where product_id = product;
    
    exception when others then
        dbms_output.put_line(sqlerrm);
end;

begin
    Add10PercToProductPrice('2A45C');
end;

-- Создайте функцию, которая вычисляет количество заказов,
-- выполненных в определенном году для определенного покупателя. 
-- Параметры – покупатель, год. товара.

-- надо изменить формат времени, если он по стандартну с строкой вместо месяца
-- ALTER SESSION SET nls_date_format='yyyy-mm-dd';

create or replace function GetAmountOrdersByYearAndCust(cust_id in number, year in number) return number
as
    counter number := 0;
begin
    select COUNT(DISTINCT(ord.CUST)) into counter
    from orders ord
    where ord.cust = cust_id and TO_CHAR(ord.order_date, 'YYYY') = year;
    
    return counter;
end;

select GetAmountOrdersByYearAndCust(2114, 2008) from dual;