create database tomtec;
use tomtec;
create table user (id int PRIMARY KEY AUTO_INCREMENT, user varchar(255), pass varchar(255), fullname varchar(255));

insert into user (user, pass, fullname) values ('admin', 'pass', 'My Administrator');
insert into user (user, pass, fullname) values ('tom', 'pass', 'Me');
insert into user (user, pass, fullname) values ('bob', 'pass', 'Da Boss');
insert into user (user, pass, fullname) values ('troy', 'pass', 'Mini Boss');
