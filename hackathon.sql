create database if not exists hackathon;
use hackathon;
-- PHẦN 1: Tạo CSDL và các bảng:
-- 1. Tạo 4 bảng
-- Bảng Customer
create table customers(
	customer_id varchar(10) primary key,
    full_name varchar(100) not null,
    phone varchar(15) not null unique,
	address varchar(200) not null
);

-- Bảng InsuranceAgents
create table InsuranceAgents(
	agent_id varchar(10) primary key,
	full_name varchar(100) not null,
	region varchar(50) not null,
    years_of_experience int not null check(years_of_experience>=0),
    commission_rate decimal(5,2) check (commission_rate>=0)
);

-- Bảng Policies
create table Policies(
	policy_id int primary key auto_increment, 
    customer_id varchar(10),
    agent_id varchar(10),
    start_date timestamp not null,
    end_date timestamp not null ,
    status enum('Active', 'Expired','Cancelled'),
    
    foreign key(customer_id) references customers(customer_id),
	foreign key(agent_id) references InsuranceAgents(agent_id)
);

-- Bảng ClaimPayments
create table ClaimPayments(
	payment_id int auto_increment primary key,
    policy_id int,
    payment_method varchar(50) not null,
    payment_date timestamp default(current_timestamp),
    amount decimal(15,2) check (amount >=0),
    
    foreign key(policy_id) references Policies(policy_id)
);
-- 2. Chèn dữ liệu 
insert into customers
values('C001', 'Nguyen Van An', '0912345678', 'Hanoi, Vietnam'),
('C002', 'Tran Thi Binh', '0923456789', 'Ho Chi Minh, Vietnam'),
('C003', 'Le Minh Chau', '0934567890', 'Da Nang, Vietnam'),
('C004', 'Pham Hoang Duc', '0945678901', 'Can Tho, Vietnam'),
('C005', 'Vu Thi Hoa', '0956789012', 'Hai Phong, Vietnam');

insert into InsuranceAgents
values('A001','Nguyen Van Minh','Mien Bac',10,5.50),
('A002','Tran Thi Lan','Mien Nam',15,7.00),
('A003','Le Hoang Nam','Mien Trung',8,4.50),
('A004','Pham Quang Huy','Mien Tay',20,8.00),
('A005','Vu Thi Mai','Mien Bac',5,3.50);

insert into Policies(customer_id, agent_id, start_date, end_date, status)
values('C001','A001', '2024-01-01 08:00:00', '2025-01-01 08:00:00', 'Expired'),
('C002','A002', '2024-02-01 09:30:00', '2025-02-01 09:30:00', 'Active'),
('C003','A003', '2023-03-02 10:00:00', '2024-03-02 10:00:00', 'Active'),
('C004','A004', '2024-05-02 14:00:00', '2025-05-02 14:00:00', 'Cancelled'),
('C005','A005', '2024-06-03 15:30:00', '2025-06-03 15:30:00', 'Active');

insert into ClaimPayments(policy_id, payment_method, payment_date, amount)
values(1,'Bank Transfer', '2024-05-01 08:45:00', 5000000.00),
(2,'Bank Transfer', '2024-06-01 10:00:00', 7500000.00),
(4,'Cash', '2024-08-02 15:00:00', 2000000.00),
(1,'Bank Transfer', '2024-09-04 11:00:00', 3000000.00),
(3,'Credit Card', '2023-10-05 14:00:00', 1500000.00);

-- 3. Thay đổi địa chỉ
update customers
set address= 'District 1, Ho Chi Minh City'
where customer_id like 'C002';

-- 4. Thay đổi trạng thái nhân viên
update InsuranceAgents
set years_of_experience= years_of_experience+2,
	commission_rate=commission_rate+1.5
where agent_id like 'A001';
-- 5. Xóa dữ liệu 
delete from Policies
where status like 'Cancelled' and start_date<'2024-06-15';

-- PHẦN 2: Truy vấn dữ liệu cơ bản
-- 6. Liệt kê danh sách các nhân viên bảo hiểm 
select agent_id, full_name, region 
from InsuranceAgents
where years_of_experience >8;

-- 7. Lấy thông tin khách hàng có tên chứa từ khóa 'Nguyen'
select customer_id, full_name, phone 
from customers 
where full_name like '%Nguyen%';
-- 8. Hiển thị danh sách tất cả hợp đồng sắp xếp giảm dần theo ngày
select policy_id, start_date, status
from Policies
order by start_date DESC;

-- 9. Lấy thông tin 3 bản ghi đầu trong bảng ClaimPayments có phương thức thanh toàn là 'Bank Transfer'
select payment_id,policy_id, payment_method, payment_date, amount
from ClaimPayments
where payment_method like 'Bank Transfer'
limit 3;

-- 10 Hiển thị thông tin nhân viên từ bảng InsuranceAgents bỏ qua 2 bản ghi đầu 
select agent_id, full_name
from InsuranceAgents
limit 3 offset 2;

-- PHẦN 3: Truy vấn dữ liệu nâng cao
-- 11. Hiển thị danh sách hợp đồng có trạng thái là active
select policy_id, c.full_name, ia.full_name, status
from Policies p join customers c on p.customer_id=c.customer_id
				join InsuranceAgents ia on p.agent_id=ia.agent_id
where status like 'Active';

-- 12. Liệt kê tất cả các nhân viên trong hệ thống bao gồm cả những nhân viên chưa từng ký hợp đồng nào
select ia.agent_id, ia.full_name, p.policy_id
from InsuranceAgents ia left join Policies p  on p.agent_id=ia.agent_id;

-- 13. Tính tống tiền bồi thường theo từng phương thức thanh toán 
select payment_method, SUM(amount) as 'Total_Payout'
from ClaimPayments 
group by payment_method;

-- 14. Thống kế số lượng hợp đồng mà mỗi nhân viên đã ký 
select p.agent_id, ia.full_name, count(policy_id) as 'Total_Policies'
from Policies p join InsuranceAgents ia on p.agent_id=ia.agent_id 
group by p.agent_id
having count(policy_id)>=1;

-- 15. Lấy thông tin chi tiết các nhân viên có mức hoa hồng cao hơn mức hoa hồng trung bình 
select agent_id, full_name, commission_rate
from InsuranceAgents 
where commission_rate>(select avg(commission_rate) from InsuranceAgents );

-- 16 Hiển thị các khách hàng đã có yêu cầu bồi thường với số tiền lớn hơn 5000000
select customer_id, full_name
from customers 
where customer_id in (
	select customer_id from Policies
    where policy_id in (
		select policy_id
        from ClaimPayments
        group by policy_id
        having sum(amount)>5000000
	)
);

-- 17 Hiển thị thông tin của tất cả các đợt chi trả bồi thường 

