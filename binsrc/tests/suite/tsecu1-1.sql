--
--  tsecu1-1.sql
--
--  $Id$
--
--  Security test #1
--
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--
--  Copyright (C) 1998-2013 OpenLink Software
--
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
--
--

--
-- Security Test, check privileges of an individual user.
--

SET ARGV[0] 0;
SET ARGV[1] 0;

-- Get the username (everybody should have access to SYS_KEYS):
select distinct USER from SYS_KEYS;
-- Set ARGV[2] to the USER name used on this connection:
SET ARGV[2] $LAST[1];

-- And only then print the starting banner:
echo BOTH "STARTED: " $ARGV[4] "  -- Privileges of user " $ARGV[2] ", part 1\n";

ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": SELECT distinct USER from SYS_KEYS; STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $ROWCNT " lines with SELECT distinct USER from SYS_KEYS;\n";

select * from SEC_TEST_1;
ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": SELECT * FROM SEC_TEST_1; STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $ROWCNT " lines with SELECT * FROM SEC_TEST_1;\n";

ECHO BOTH $IF $EQU $COLCNT 3 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $COLCNT " columns with SELECT * FROM SEC_TEST_1;\n";

select a from SEC_TEST_2;
ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": SELECT a FROM SEC_TEST_2; STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $ROWCNT " lines with SELECT a FROM SEC_TEST_2;\n";

ECHO BOTH $IF $EQU $COLCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $COLCNT " columns with SELECT a FROM SEC_TEST_2;\n";

ECHO BOTH $IF $EQU $LAST[1] 11 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": column  a  contains value " $LAST[1] "\n";


--
-- Should produce: *** Error 42000: Access denied for column b.
--
select * from SEC_TEST_2;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": SELECT * FROM SEC_TEST_2; (WITHOUT permission to all columns) STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce: *** Error 42000: _ROW requires select grant on the entire table.
--
select row_table(_ROW) from SEC_TEST_2;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": SELECT row_table(_ROW) FROM SEC_TEST_2; (WITHOUT permission to all columns) STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should work for all users:
--
call secp_1 (3);

ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Calling secp_1(3), which has been granted for public: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- Note!
-- $RETVAL doesn't work with ISQLODBC in Windows NT because Microsoft's
-- ODBC driver manager doesn't let SQL_RETURN_VALUE parameters pass
-- through it. Use directly linked ISQL instead!

ECHO BOTH $IF $EQU $RETVAL 33 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Result of which was=" $RETVAL "\n";

--
-- Should work only for users u1 and u5:
--
call secp_2 (11);

ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Calling secp_2(11), which has been granted for u1: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $EQU $RETVAL 242 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Result of which was=" $RETVAL "\n";

create procedure sec_u1proc (in q integer) { return (33*q); };
PROCEDURES SEC_U1PROC;
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $ROWCNT " procedures with name like 'sec_u1proc' found after CREATE PROCEDURE sec_u1proc\n";

ECHO BOTH $IF $EQU $LAST[2] "U1" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Owner of the procedure: " $LAST[2] "\n";

ECHO BOTH $IF $EQU $LAST[3] "SEC_U1PROC" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Name of the procedure created: " $LAST[3] "\n";

--
-- Should work only for this user and users with dba privileges:
--
call sec_u1proc (-2);

ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Calling sec_u1proc(-2), which has been created by u1: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $EQU $RETVAL -66 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Result of which was=" $RETVAL "\n";

--
-- Should produce for all ordinary users:
-- *** Error 42000: No insert or insert/delete permission for insert / insert replacing
--
insert into SEC_TEST_3 values (1661, 1661, 1661);
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": inserting WITHOUT permission into SEC_TEST_3: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should succeed for u1 and u5:
--
insert into SEC_TEST_4 values (14641, 14641, 14641);
ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": inserting WITH permission into SEC_TEST_4: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce for all ordinary users *** Error 42000: Access denied for column a.
--
delete from SEC_TEST_4 where a = 5;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": deleting from SEC_TEST_4 WITHOUT permission to column a: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should work for u1, u2 and u5:
--
delete from SEC_TEST_4;
ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": deleting from SEC_TEST_4 WITHOUT referencing column a: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce for all ordinary users:
-- *** Error 42000: Permission denied for delete.
--
delete from SEC_TEST_1;

ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": deleting from SEC_TEST_1 WITHOUT permission to do it: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce for all ordinary users:
-- *** Error 42000: Update of a not allowed
--
update SEC_TEST_3 set a = 111;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": updating column a of SEC_TEST_3 WITHOUT permission to that column: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should work for u1, u3, u4 and u5:
--
update SEC_TEST_3 set b = 1;
ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": updating SEC_TEST_3 WITH permission to column b: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce for all ordinary users:
-- *** Error 42000: Update of b not allowed
--
update SEC_TEST_4 set b = 1;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": updating SEC_TEST_4 WITHOUT permission to do it: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Check that SQLTablePrivileges and SQLColumnPrivileges work also
-- for ordinary users (i.e. that internal procedures table_privileges
-- and column_privileges has been permitted for public:
-- Note that the implementation might later restrict grants shown
-- only to the calling user's own grants, so we doesn't check here
-- the rowcounts returned and other fields as thoroughly as in
-- tsec-ini.sql
--

TABLEPRIVILEGES;

ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Doing SQLTablePrivileges as ordinary user: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $NEQ $ROWCNT 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $ROWCNT " table grants found.\n";

--
-- Same with SQLColumnPrivileges:
--

COLUMNPRIVILEGES SEC_TEST_2;

ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Doing SQLColumnPrivileges as ordinary user: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

ECHO BOTH $IF $NEQ $ROWCNT 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": " $ROWCNT " column grants on table SEC_TEST_2 found.\n";

ECHO BOTH $IF $EQU $LAST[3] "SEC_TEST_2" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Granted on table " $LAST[3] "\n";

ECHO BOTH $IF $EQU $LAST[4] "A" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Granted on column " $LAST[4] "\n";

--
-- And finally, password changing and related tests:
--

--
-- Should produce: *** Error 42000: Incorrect old password in set password
--
set password wrongpass newpass;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Changing password with incorrect old password: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should work:
--
set password u1 u1pass;
ECHO BOTH $IF $EQU $STATE "OK" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Changing password with correct old password: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce: *** Error 42000:  Access denied for column U_PASSWORD
--
select U_PASSWORD from SYS_USERS;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Selecting WITHOUT permission from SYS_USERS: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce: *** Error 42000: Permission denied. Must be member of dba group.
--
set user group u1 dba;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Setting own user group WITHOUT permission: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- Should produce: *** Error 42000: Permission denied. Must be member of dba group.
--
grant select on SEC_TEST_4 to u1;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Granting privileges WITHOUT permission: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";


ECHO BOTH "COMPLETED WITH " $ARGV[0] " FAILED, " $ARGV[1] " PASSED: " $ARGV[4] "  -- Privileges of user " $ARGV[2] ", part 1\n";





select * from T1;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
ECHO BOTH ": T1 not grant to u1\n";


select * from SEC_T1;
ECHO BOTH $IF $EQU $ROWCNT 20 "PASSED" "***FAILED";
ECHO BOTH ": SEC_T1 view granted to U1\n";

create table U1_T1 (ROW_NO integer, STRING1 varchar, STRING2 varchar, TIME1 timestamp,
	primary key (ROW_NO));
insert into U1_T1 (ROW_NO, STRING1, STRING2) select ROW_NO, STRING1, STRING2 from SEC_T1;
grant select on U1_T1 to U2;


grant select on SEC_T1 to public;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
ECHO BOTH ": forbidden re-grant of SEC_T1\n";

create view SEC_T1_U1 as select * from T1;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
ECHO BOTH ": forbidden view to T1\n";

create view U1_T1_V as select * from U1_T1, T1 where T1.ROW_NO = 111;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
ECHO BOTH ": forbidden join view 2 \n";

select * from U1_T1;
ECHO BOTH $IF $EQU $ROWCNT 20 "PASSED" "***FAILED";
ECHO BOTH ": U1_T1 view granted to U1\n";

create view U1_T2 as select * from T2;
grant select, insert, update, delete on U1_T2 to U3;
grant select on U1_T1 to U3;


create view U1_T1_V as select * from U1_T1;
-- grant select, update (ROW_NO, STRING1) on U1_T1_V to U3;
grant select, update  on U1_T1_V to U3;

------- proc

pda1 (11);
ECHO BOTH $IF $EQU $STATE 42001 "PASSED" "***FAILED";
ECHO BOTH ": pdba1 state " $STATE "\n";

pda2 (11);
ECHO BOTH $IF $EQU $STATE 42001 "PASSED" "***FAILED";
ECHO BOTH ": pdba1 state " $STATE "\n";




------- Trigger



create table u1_tt (k integer, d integer, d2 integer);

create trigger u1_tt_u after update (d) on u1_tt referencing new as n
{
  dbg_obj_print ('d updated to ', d);
  update u1_tt set d2 = pdba2 (n.d) where k = n.k;
}

grant select, update on u1_tt to U3;

insert into u1_tt (k) values (1);
insert into u1_tt (k) values (2);

update u1_tt set d = 12;

select d2 from u1_tt;
ECHO BOTH $IF $EQU $LAST[1] 12 "PASSED" "***FAILED";
ECHO BOTH ": u1 trigger update = " $LAST[1] "\n";

alter table u1_tt add x integer;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
ECHO BOTH ": alter by owner 1 ate " $STATE "\n";

alter table u1_tt drop x;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
ECHO BOTH ": alter by owner 2 ate " $STATE "\n";

alter table u1_tt rename temp;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
ECHO BOTH ": alter by owner 3 ate " $STATE "\n";

alter table temp rename u1_tt;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
ECHO BOTH ": alter by owner 4 ate " $STATE "\n";


create view forbidden as select * from SEC_T1, T1;
ECHO BOTH $IF $EQU $STATE 42000 "PASSED" "***FAILED";
ECHO BOTH ": unauthorized view state " $STATE "\n";
