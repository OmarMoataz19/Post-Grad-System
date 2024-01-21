
use M2
set dateformat dmy 
--								TABLES
create table PostGradUser(
id int Primary Key identity , 
email varchar (50),
password varchar(20));
 
create table Admin(
id int Primary Key ,
Foreign Key (id) references PostGradUser on delete cascade on update cascade);

create table GucianStudent(
id int,
firstName varchar(20),
lastName varchar(20),
type varchar (10),
faculty varchar (20),
address varchar(50),
GPA real,
undergradID varchar(10),
Primary Key (id),
Foreign Key(id) references PostGradUser on delete cascade on update cascade);

create table NonGucianStudent(
id int ,
firstName varchar(20),
lastName varchar(20),
type varchar (10),
faculty varchar (20),
address varchar(50),
GPA real,
Primary Key (id),
Foreign Key(id) references PostGradUser on delete cascade on update cascade);


create table GucStudentPhoneNumber(
id int ,
phone varchar(20),
Primary Key(id,phone),
Foreign Key (id) references GucianStudent on delete cascade on update cascade);

create table NonGucStudentPhoneNumber(
id int,
phone varchar(20),
Primary Key (id,phone),
Foreign Key(id) references NonGucianStudent on delete cascade on update cascade);

create table Course(
id int identity ,
fees decimal(18,2),
creditHours int,
code varchar(10),
Primary Key (id));

create table Supervisor(
id int ,
name varchar(50),
faculty varchar(20),
Primary Key (id),
Foreign Key(id) references PostGradUser on delete cascade on update cascade);

create table Payment (
id int identity ,
amount decimal (18,2) ,
no_Installments int,
fundPercentage decimal,
Primary Key( id));

create table Thesis ( 
serialNumber int identity,
field varchar(20),
type varchar(20),
title varchar (50),
startDate Date ,
endDate Date,
defenseDate Datetime,
years As year(endDate)-year(startDate), 
grade decimal(10,2),
payment_id int,
noExtension int,
Primary Key(serialNumber),
Foreign Key(payment_id) references Payment on delete cascade on update cascade);

create table Publication(
id int identity ,
title Varchar(50),
date dateTime,
place varchar (50),
accepted bit,
host Varchar(50),
Primary Key (id));


create table Examiner (
id int ,
name varchar(20),
fieldOfWork varchar(20),
isNational bit,
Primary Key (id),
Foreign Key(id) references PostGradUser on delete cascade on update cascade);


create table Defense ( 
serialNumber int,
date datetime,
location varchar(15),
grade decimal(10,2),
Primary Key( serialNumber,date),
Foreign Key( serialNumber) references Thesis on delete cascade on update cascade);

create table GUCianProgressReport(
sid int,
no int identity,
date date,
eval int,
description varchar(200),
state int, 
thesisSerialNumber int,
supid int,
Primary Key(sid,no),
Foreign Key(sid) references GucianStudent on delete cascade on update cascade,
Foreign Key(thesisSerialNumber) references Thesis on delete cascade on update cascade,
Foreign Key (supid) references Supervisor on delete no action on update no action);

create table NonGucianProgressReport(
sid int,
no int identity ,
date date,
eval int,
state int , 
description varchar(200),
thesisSerialNumber int,
supid int,
Primary Key(sid,no),
Foreign Key(sid) references NonGucianStudent on delete cascade on update cascade,
Foreign Key(thesisSerialNumber) references Thesis on delete cascade on update cascade,
Foreign Key (supid) references Supervisor on delete no action on update no action);

create table Installment (
date date,
paymentId int,
amount decimal(18,2),
done bit,
Primary Key(date,paymentId),
Foreign Key(paymentId) references Payment on delete cascade on update cascade);

create table NonGucianStudentPayForCourse(
sid int,
paymentNo int,
cid int,
Primary Key(sid,paymentNo,cid),
Foreign Key (sid) references NonGucianStudent on delete cascade on update cascade,
Foreign Key(paymentNo) references Payment on delete cascade on update cascade,
Foreign Key(cid) references Course on delete cascade on update cascade);

create table NonGucianStudentTakeCourse(
sid int,
cid int,
grade decimal(10,2),
Primary Key(sid,cid),
Foreign Key(sid) references NonGucianStudent on delete cascade on update cascade,
Foreign Key(cid) references Course on delete cascade on update cascade);

create table GUCianStudentRegisterThesis(
sid int,
supid int,
serial_no int,
Primary Key (sid,supid,serial_no),
Foreign Key(sid) references GucianStudent on delete cascade on update cascade,
Foreign Key( supid) references Supervisor on delete no action on update no action,
Foreign Key( serial_no) references Thesis on delete cascade on update cascade);

create table NonGUCianStudentRegisterThesis(
sid int,
supid int,
serial_no int ,
Primary Key (sid,supid,serial_no),
Foreign Key(sid) references NonGucianStudent on delete cascade on update cascade,
Foreign Key(supid) references Supervisor on delete no action on update no action,
Foreign Key(serial_no) references Thesis on delete cascade on update cascade);

create table ExaminerEvaluateDefense(
date datetime,
serialNo int,
examinerId int,
comment varchar(300),
Primary Key (date, serialNo,examinerId),
Foreign Key(serialNo,date) references Defense on delete cascade on update cascade,
Foreign Key(examinerId) references Examiner on delete cascade on update cascade);

create table ThesisHasPublication(
serialNo int,
pubid int ,
Primary Key( serialNo,pubid),
Foreign Key( serialNo) references Thesis on delete cascade on update cascade,
Foreign Key( pubid) references Publication on delete cascade on update cascade);

















 --									PROCEDURES 

	--                                     1 As an unregistered user I should be able to:

--1 a)  Register to the website as a student by using my name (First and last name), password, faculty, email, and address.
GO
CREATE PROC StudentRegister
@first_name varchar(20), 
@last_name varchar(20), 
@password varchar(20), 
@faculty varchar(20),
@Gucian bit, 
@email varchar(50), 
@address varchar(50),
@type varchar (50)
AS
declare @studentId int 
INSERT  INTO PostGradUser (email, password)
VALUES (@email, @password)
set @studentId=scope_identity()--check law de scope identity
IF(@Gucian=1)
	INSERT  INTO GucianStudent (id,firstName, lastName,type, faculty, address) 
	VALUES (@studentId,@first_name, @last_name,@type, @faculty, @address)
ELSE
	INSERT  INTO NonGucianStudent (id,firstName, lastName,type, faculty, address) 
	VALUES (@studentId,@first_name, @last_name,@type, @faculty, @address)
GO




--1 b)  Register to the website as a supervisor by using my name (First and last name), password, faculty, email, and address.
GO
CREATE PROC SupervisorRegister
@first_name varchar(20), 
@last_name varchar(20), 
@password varchar(20), 
@faculty varchar(20),
@email varchar(50)
AS
declare @supervisorID int

INSERT  INTO PostGradUser (email, password)
VALUES (@email, @password)
set @supervisorID=scope_identity()
INSERT  INTO Supervisor (id,name, faculty) 
VALUES (@supervisorID,@first_name + ' ' + @last_name, @faculty)
GO


--                              2 As any registered User I should be able to:


--2 a) login using my username and password.


--2 b) add my mobile number(s).
GO
CREATE PROC addMobile
@ID int, 
@mobile_number varchar(20)
AS
IF(EXISTS(SELECT id FROM GucianStudent WHERE id = @ID))
	INSERT INTO GUCStudentPhoneNumber VALUES(@ID, @mobile_number)
ELSE IF(EXISTS(SELECT id FROM NonGucianStudent WHERE id = @ID))
	INSERT INTO NonGUCStudentPhoneNumber VALUES(@ID, @mobile_number)
GO


--                                    3 As an admin I should be able to:


--3 a) List all supervisors in the system.
GO
CREATE PROC AdminListSup
AS
SELECT *
FROM Supervisor
GO


--3 b)  View the profile of any supervisor that contains all his/her information.
GO
CREATE PROC AdminViewSupervisorProfile
@supId int
AS
SELECT *
FROM Supervisor
WHERE @supID= Supervisor.id
GO

--3 c)  List all Theses in the system.
GO
CREATE PROC AdminViewAllTheses
AS
SELECT *
FROM Thesis
GO


--3 d)   List the number of on going theses.
GO
CREATE PROC AdminViewOnGoingTheses
@thesisCount int  output 
AS
SELECT @thesisCount=COUNT(*) 
FROM Thesis
WHERE CURRENT_TIMESTAMP >= Thesis.startDate AND CURRENT_TIMESTAMP < Thesis.endDate
return @thesisCount
GO


--3 e) List all supervisors’ names currently supervising students, theses title, student name
GO
CREATE PROC AdminViewStudentThesisBySupervisor
AS
(SELECT S.name, T.title, GS.firstName + ' ' + GS.lastName AS 'Student Name'
FROM Supervisor S INNER JOIN GUCianStudentRegisterThesis GRS ON S.id = GRS.supid 
				  INNER JOIN Thesis T ON GRS.serial_no = T.serialNumber 
				  INNER JOIN GucianStudent GS ON GRS.sid = GS.id
WHERE CURRENT_TIMESTAMP >= T.startDate AND CURRENT_TIMESTAMP < T.endDate)
	UNION
(SELECT S.name, T.title, NGS.firstName + ' ' + NGS.lastName AS 'Student Name'
FROM Supervisor S INNER JOIN NonGUCianStudentRegisterThesis NGRS ON S.id = NGRS.supid 
				  INNER JOIN Thesis T ON NGRS.serial_no = T.serialNumber 
				  INNER JOIN NonGucianStudent NGS ON NGRS.sid = NGS.id
WHERE CURRENT_TIMESTAMP >= T.startDate AND CURRENT_TIMESTAMP < T.endDate)
GO


--3 f) List nonGucians names, course code, and respective grade.
GO
CREATE PROC AdminListNonGucianCourse
@courseID int
AS
SELECT S.firstName + ' ' + S.LastName AS 'Student Name', C.code, T.grade
FROM NonGucianStudent S INNER JOIN NonGucianStudentTakeCourse T ON S.id=T.sid 
						INNER JOIN Course C ON T.cid = C.id
WHERE @courseID = C.id
GO


--3 g)  Update the number of thesis extension by 1.
GO
CREATE PROC AdminUpdateExtension
@ThesisSerialNo int
AS
UPDATE Thesis
SET noExtension += 1
WHERE @ThesisSerialNo = serialNumber
GO


--3 h) Issue a thesis payment.
CREATE PROC AdminIssueThesisPayment
@ThesisSerialNo int,
@amount decimal(18,2), 
@noOfInstallments int , 
@fundPercentage decimal(4,3),
@Success BIT output 
AS
BEGIN

IF(EXISTS(select serialNumber from Thesis where serialNumber= @ThesisSerialNo))
BEGIN
Insert into Payment(no_Installments,amount,fundpercentage)
values (@noOfInstallments,@amount,@fundPercentage)
DECLARE @PAYMENTNO int 
set @PAYMENTNO=scope_identity()
UPDATE THESIS 
set payment_id= @PAYMENTNO
where serialNumber=@ThesisSerialNo
set @Success='1'
END
else
set @Success='0'
return @success
END

--3 i) View the profile of any student that contains all his/her information.
GO
CREATE PROC AdminViewStudentProfile
@sid int
AS
IF(EXISTS(SELECT id FROM GucianStudent WHERE id = @sid))
	SELECT *
	FROM GucianStudent
	WHERE id = @sid
ELSE IF(EXISTS(SELECT id FROM NonGucianStudent WHERE id = @sid))
	SELECT *
	FROM NonGucianStudent
	WHERE id = @sid
GO


--3 j) Issue installments as per the number of installments for a certain payment every six months starting from the entered date.

GO
CREATE PROC AdminIssueInstallPayment
@paymentID INT, 
@InstallStartDate DATE
AS
DECLARE @n INT
SET @n = 0

DECLARE @noOfInstallments INT
SELECT @noOfInstallments = P.no_Installments
FROM Payment P
WHERE P.id = @paymentID

DECLARE @amount INT
SELECT @amount = P.amount/@noOfInstallments
FROM Payment P
WHERE P.id = @paymentID

DECLARE @newDate DATE
SET @newDate = @InstallStartDate
WHILE @n < @noOfInstallments
	BEGIN
		SET @n = @n + 1
		INSERT INTO Installment (date, paymentId, amount, done) VALUES (@newDate, @paymentID, @amount, '1')
		SET @newDate = DATEADD(month, 6, @newDate)
	END
GO



--3 k) List the title(s) of accepted publication(s) per thesis.
GO
CREATE PROC AdminListAcceptPublication
AS
SELECT  T.serialNumber,T.title, P.title
FROM Publication P INNER JOIN ThesisHasPublication TP ON P.id=TP.pubid 
				   INNER JOIN Thesis T ON TP.serialNo=T.serialNumber
WHERE P.accepted = '1' --Assuming 1 is accepted
GROUP BY T.serialNumber, T.title, P.title
GO
	

--3 l) 1 Add courses to students.
GO
CREATE PROC  AddCourse
@courseCode varchar(10), 
@creditHrs int, 
@fees decimal
AS
INSERT INTO Course (fees, creditHours, code) VALUES (@fees,@creditHrs, @courseCode)
GO
 --3 l) 2 Link courses to students.
GO
CREATE PROC linkCourseStudent
@courseID int,
@studentID int
AS
INSERT INTO NonGucianStudentTakeCourse (cid,sid) VALUES (@courseID, @StudentID)
GO
--3 l) 3 Add course grades to students.
GO
CREATE PROC addStudentCourseGrade
@courseID int,
@studentID int,
@grade decimal
AS
UPDATE NonGucianStudentTakeCourse 
SET grade = @grade
WHERE cid = @courseID AND sid = @studentID
GO


--3 m) View examiners and supervisor(s) names attending a thesis defense taking place on a certain date.

GO
CREATE PROC ViewExamSupDefense
@defenseDate datetime
AS
SELECT E.name AS 'Examiner', S.name AS 'Supervisor'
FROM Examiner E INNER JOIN ExaminerEvaluateDefense ED ON E.id = ED.examinerId
				INNER JOIN GUCianStudentRegisterThesis G ON G.serial_no = ED.serialNo
				INNER JOIN Supervisor S ON S.id= G.supid
				WHERE ED.date = @defenseDate
UNION
SELECT E.name AS 'Examiner', S.name AS 'Supervisor'
FROM Examiner E INNER JOIN ExaminerEvaluateDefense ED ON E.id = ED.examinerId
				INNER JOIN NonGUCianStudentRegisterThesis NG ON NG.serial_no = ED.serialNo
				INNER JOIN Supervisor S ON S.id= NG.supid
				WHERE ED.date = @defenseDate

GO


--                                  4 As a supervisor I am able to :

--4 a)  Evaluate a student’s progress report, and give evaluation value 0 to 3.
GO 
CREATE PROC  EvaluateProgressReport
@supervisorID int, 
@thesisSerialNo int, 
@progressReportNo int, 
@evaluation int
AS
IF(EXISTS(SELECT supid, serial_no
		  FROM GUCianStudentRegisterThesis 
		  WHERE supid = @supervisorID AND serial_no = @thesisSerialNo ))
		
	UPDATE  GUCianProgressReport
	SET eval = @evaluation
	WHERE  supid = @supervisorID AND thesisSerialNumber = @thesisSerialNo  AND no = @progressReportNo
ELSE IF(EXISTS(SELECT supid, serial_no 
		  FROM NonGUCianStudentRegisterThesis 
		  WHERE supid = @supervisorID AND serial_no = @thesisSerialNo  ))
	UPDATE  NonGUCianProgressReport
	SET eval = @evaluation
	WHERE  supid = @supervisorID AND thesisSerialNumber = @thesisSerialNo  AND no = @progressReportNo
GO


--4 b)  View all my students’s names and years spent in the thesis.
GO
CREATE PROC ViewSupStudentsYears
@supervisorID int
AS
SELECT G.firstName + ' ' + G.lastName AS 'Student Name', T.years
FROM			  GUCianStudentRegisterThesis GRT
				  INNER JOIN GucianStudent G On GRT.sid = G.id         
				  INNER JOIN Thesis T ON GRT.serial_no = T.serialNumber
				  where GRT.supid=@supervisorID
UNION
SELECT NG.firstName + ' ' + NG.lastName AS 'Student Name', T.years
FROM			  NonGUCianStudentRegisterThesis NGRT 
				  INNER JOIN NonGucianStudent NG On NGRT.sid = NG.id
				  INNER JOIN Thesis T ON NGRT.serial_no = T.serialNumber
				  where NGRT.supid=@supervisorID
GO

--4 c) 1 View my profile's personal information.
GO
CREATE PROC SupViewProfile
@supervisorID int
AS
SELECT *
FROM Supervisor
WHERE id = @supervisorID
GO

--4 c) 2 Update my personal information.
GO
CREATE PROC UpdateSupProfile
@supervisorID int,
@name varchar(20),
@faculty varchar(20)
AS
UPDATE Supervisor
SET name = @name, faculty = @faculty
WHERE id = @supervisorID

--4 d) View all publications of a student.
GO
CREATE PROC ViewAStudentPublications
@StudentID int
AS
IF(EXISTS(SELECT id FROM GucianStudent WHERE id = @StudentID))
	SELECT P.id,P.title, P.date, P.place, P.accepted, P.host
	FROM Publication P INNER JOIN ThesisHasPublication TP ON P.id = TP.pubid
					   INNER JOIN GUCianStudentRegisterThesis GRT ON TP.serialNo = GRT.serial_no
						WHERE GRT.sid=@StudentID  
ELSE IF(EXISTS(SELECT id FROM NonGucianStudent WHERE id = @StudentID))
	SELECT P.id,P.title, P.date, P.place, P.accepted, P.host
	FROM Publication P INNER JOIN ThesisHasPublication TP ON P.id = TP.pubid
					   INNER JOIN NonGUCianStudentRegisterThesis NGRT ON TP.serialNo = NGRT.serial_no
							WHERE NGRT.sid=@StudentID 
GO

--4 e) 1 Add defense for a thesis, for Gucian.
GO
CREATE PROC AddDefenseGucian
@ThesisSerialNo int , 
@DefenseDate Datetime , 
@DefenseLocation varchar(15)
AS
INSERT INTO Defense(serialNumber,date,location)
VALUES(@ThesisSerialNo,@DefenseDate,@DefenseLocation)
GO

--4 e) 2 Add defense for a thesis, for nonGucian students all courses’ grades should be greater than 50 percent.

GO
CREATE PROC AddDefenseNonGucian
@ThesisSerialNo int , 
@DefenseDate Datetime , 
@DefenseLocation varchar(15)
AS
IF(50 < ALL (SELECT NGTC.grade FROM NonGucianStudentTakeCourse NGTC INNER JOIN NonGucianStudentRegisterThesis NGRT ON NGTC.sid = NGRT.sid 
	where NGRT.serial_no=@ThesisSerialNo))
	INSERT INTO Defense(serialNumber,date,location)
	VALUES (@ThesisSerialNo, @DefenseDate, @DefenseLocation)
GO

--4 f)  Add examiner(s) for a defense.
GO
CREATE PROC AddExaminer
@ThesisSerialNo int , 
@DefenseDate Datetime ,
@ExaminerName varchar(20),
@National bit, 
@fieldOfWork varchar(20)
AS 
insert into postGradUser(email,password)
values(null,null)
declare @examinerID int
set @examinerID=scope_identity()
INSERT INTO Examiner (id,name, isNational, fieldOfWork) 
VALUES (@examinerID,@ExaminerName,@National,@fieldOfWork)
INSERT INTO ExaminerEvaluateDefense (date,serialNo,examinerId)
VALUES(@DefenseDate,@ThesisSerialNo,@examinerID)



--4 g)  Cancel a Thesis if the evaluation of the last progress report is zero.
GO
CREATE PROC CancelThesis 
@ThesisSerialNo int
AS
Declare @maxDate Date
Declare @evaluation int 
IF(exists(SELECT thesisSerialNumber from GUCianProgressReport where thesisSerialNumber=@ThesisSerialNo))
BEGIN

SELECT @maxDate=max(date)
from GUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo

SELECT	@evaluation=eval 
from GUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo  AND  date=@maxdate

IF(@evaluation=0)
BEGIN
DELETE 
From Thesis
where @ThesisSerialNo=SerialNumber
END
END
IF(exists(SELECT thesisSerialNumber from NonGUCianProgressReport where thesisSerialNumber=@ThesisSerialNo))
BEGIN
SELECT @maxDate=max(date)
from NonGUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo

SELECT	@evaluation=eval 
from NonGUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo  AND  @maxDate= date 

IF(@evaluation=0)
BEGIN
DELETE 
From Thesis
where @ThesisSerialNo=SerialNumber
END
END




GO

--4 h)  Add a grade for a thesis.
GO
CREATE PROC AddGrade 
 @ThesisSerialNo int,
 @grade decimal (10,2) 
 AS
 UPDATE Thesis
 Set grade= @grade

 WHERE serialNumber =@ThesisSerialNo


--                             5 As an examiner I should be able to:


--5 a) Add grade for a defense.
GO

--5 b)  Add comments for a defense.


--                   6 As a registered student I should be able to:



--6 a)  View my profile that contains all my information.
GO
CREATE PROC viewMyProfile
@studentId int
AS
IF(exists(select id from GucianStudent where id=@studentId))
BEGIN
Select *
From GucianStudent
where id=@studentId
END
IF(exists(select id from NonGucianStudent where id=@studentId))
BEGIN
Select *
From NonGucianStudent
where id=@studentId
END

GO

--6 b) Edit my profile.
GO
CREATE PROC editMyProfile
@studentID int,
@firstName varchar(20),
@lastName varchar(20),
@password varchar(20),
@email varchar(50),
@address varchar(50),
@type varchar(10)
AS
IF (EXISTS(SELECT id FROM GucianStudent WHERE id = @studentID))
	BEGIN
		UPDATE PostGradUser
		SET  password = @password, email = @email
		WHERE id = @studentID
		UPDATE GucianStudent
		SET  firstName = @firstName, lastName = @lastName, address = @address, type = @type
		WHERE id = @studentId
	
	END
ELSE
	BEGIN
		UPDATE PostGradUser
		SET  password = @password, email = @email
		WHERE id = @studentID
		UPDATE NonGucianStudent
		SET  firstName = @firstName, lastName = @lastName, address = @address, type = @type
		WHERE id = @studentId
		
	END
GO

--6 c)  As a Gucian graduate, add my undergarduate ID.
GO 
CREATE PROC addUndergradID
@studentID int,
@undergradID varchar(10)
AS
UPDATE GucianStudent
SET undergradID = @undergradID
WHERE id = @studentID
GO

--6 d) As a nonGucian student, view my courses’ grades.
GO 
CREATE PROC ViewCoursesGrades
@studentID int
AS
SELECT C.code, NGT.grade
FROM NonGucianStudentTakeCourse NGT INNER JOIN Course C ON NGT.cid = C.id
WHERE sid = @studentID
GO

--6 e)  1 View all my course payments and installments.
GO
CREATE PROC ViewCoursePaymentsInstall
@studentID int
AS
SELECT NGP.cid, P.id, P.amount AS 'Payment Amount', P.no_Installments, P.fundPercentage, I.date, I.amount AS 'Installment Amount', I.done
FROM Payment P INNER JOIN NonGucianStudentPayForCourse NGP ON P.id = NGP.paymentNo INNER JOIN Installment I ON I.paymentId = NGP.paymentNo
WHERE NGP.sid = @studentID
GROUP BY NGP.cid,P.id, P.amount, P.no_Installments, P.fundPercentage, I.date, I.amount, I.done
GO

--6 e) 2 View all my thesis payments and installments.
GO
CREATE PROC ViewThesisPaymentsInstall
@studentID int
AS
IF(EXISTS(SELECT sid FROM NonGucianStudentRegisterThesis WHERE sid = @studentID))
	BEGIN
		SELECT T.serialNumber, P.id, P.amount AS 'Payment Amount', P.no_Installments, P.fundPercentage, I.date, I.amount AS 'Installment Amount', I.done
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id INNER JOIN Thesis T ON P.id = T.payment_id INNER JOIN NonGucianStudentRegisterThesis NGR ON T.serialNumber = NGR.serial_no
		WHERE NGR.sid = @studentID
		GROUP BY T.serialNumber  , P.id, P.amount , P.no_Installments, P.fundPercentage, I.date, I.amount , I.done
	END
ELSE
	BEGIN
		SELECT T.serialNumber, P.id, P.amount AS 'Payment Amount', P.no_Installments, P.fundPercentage, I.date, I.amount AS 'Installment Amount', I.done
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id INNER JOIN Thesis T ON P.id = T.payment_id INNER JOIN GucianStudentRegisterThesis GR ON T.serialNumber = GR.serial_no
		WHERE GR.sid = @studentID
		GROUP BY T.serialNumber , P.id, P.amount, P.no_Installments, P.fundPercentage, I.date, I.amount , I.done
	END
GO

--6 e) 3 View upcoming installments.
GO
CREATE PROC ViewUpcomingInstallments
@studentID int
AS
IF(EXISTS(SELECT sid FROM GucianStudentRegisterThesis WHERE sid = @studentID))
	BEGIN
		SELECT I.paymentId, I.date, I.amount, I.done
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id INNER JOIN Thesis T ON P.id = T.payment_id INNER JOIN GucianStudentRegisterThesis GR ON T.serialNumber = GR.serial_no
		WHERE GR.sid = @studentID AND I.date > CURRENT_TIMESTAMP AND I.done='0' --done de sah wala laa
	END
ELSE
	BEGIN 
		(SELECT I.*
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id  INNER JOIN Thesis T ON P.id = T.payment_id INNER JOIN NonGucianStudentRegisterThesis NGR ON T.serialNumber = NGR.serial_no
		WHERE NGR.sid = @studentID AND I.date > CURRENT_TIMESTAMP AND I.done='0')
		UNION
		(
		Select I.*
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id INNER JOIN NonGucianStudentPayForCourse NGC ON P.id = NGC.paymentNo
		WHERE NGC.sid=@studentID AND I.date > CURRENT_TIMESTAMP AND I.done='0'
		)

	END
GO

--6 e) 4 View missed installments.
GO
CREATE PROC ViewMissedInstallments
@studentID int
AS
IF(EXISTS(SELECT sid FROM GucianStudentRegisterThesis WHERE sid = @studentID))
	BEGIN
		SELECT I.paymentId, I.date, I.amount, I.done
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id INNER JOIN Thesis T ON P.id = T.payment_id INNER JOIN GucianStudentRegisterThesis GR ON T.serialNumber = GR.serial_no
		WHERE GR.sid = @studentID AND I.date < CURRENT_TIMESTAMP AND I.done='0' 
	END
ELSE
	BEGIN 
		(SELECT I.*
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id  INNER JOIN Thesis T ON P.id = T.payment_id INNER JOIN NonGucianStudentRegisterThesis NGR ON T.serialNumber = NGR.serial_no
		WHERE NGR.sid = @studentID AND I.date < CURRENT_TIMESTAMP AND I.done='0')
		UNION
		(
		Select I.*
		FROM Installment I INNER JOIN Payment P ON I.paymentId = P.id INNER JOIN NonGucianStudentPayForCourse NGC ON P.id = NGC.paymentNo
		WHERE NGC.sid=@studentID AND I.date < CURRENT_TIMESTAMP AND I.done='0'
		)
	END
GO

--6 f 1)  Add my progress report(s).
GO
CREATE PROC AddProgressReport
@thesisSerialNo int ,
@progressReportDate date
AS
Declare @studentID int
Declare @supervisorID int
if(exists(select * From GUCianStudentRegisterThesis where serial_no=@thesisSerialNo))
BEGIN
select @studentID=sid, @supervisorID=supid
FROM GUCianStudentRegisterThesis
where serial_no=@thesisSerialNo
insert into GUCianProgressReport(sid,date,thesisSerialNumber,supid)
Values (@studentID,@progressReportDate,@thesisSerialNo,@supervisorID)
END

ELSE 
BEGIN
select @studentID=sid, @supervisorID=supid
FROM NonGUCianStudentRegisterThesis
where serial_no=@thesisSerialNo
insert into NonGUCianProgressReport(sid,date,thesisSerialNumber,supid)
Values (@studentID,@progressReportDate,@thesisSerialNo,@supervisorID)
END

GO
--6 f 2) Fill my progress report(s).
 CREATE PROC FillProgressReport
@thesisSerialNo int,
@progressReportNo int,
@state int, 
@description varchar(200)
AS
if(exists(select * From GUCianStudentRegisterThesis where serial_no=@thesisSerialNo))
BEGIN
UPDATE GUCianProgressReport
SET state =@state ,description = @description
WHERE thesisSerialNumber=@thesisSerialNo AND no=@progressReportNo
END

ELSE
BEGIN
UPDATE NonGUCianProgressReport
SET state =@state ,description = @description
WHERE thesisSerialNumber=@thesisSerialNo AND no=@progressReportNo

END

--6 g) View my progress report(s) evaluations.
GO
CREATE PROC ViewEvalProgressReport
@thesisSerialNo int,
@progressReportNo int
AS
IF(EXISTS(SELECT thesisSerialNumber, no FROM GUCianProgressReport)) 
	BEGIN
	SELECT eval
	FROM GUCianProgressReport
	WHERE thesisSerialNumber = @thesisSerialNo AND no = @progressReportNo
	END
ELSE
	BEGIN
	SELECT eval
	FROM NonGUCianProgressReport
	WHERE thesisSerialNumber = @thesisSerialNo AND no = @progressReportNo
	END
GO

--6 h)  Add publication.
GO
CREATE PROC addPublication
@title varchar(50),
@pubDate datetime,
@host varchar(50),
@place varchar(50),
@accepted bit
AS
INSERT INTO Publication(title, date, place, accepted, host) VALUES (@title, @pubDate, @place, @accepted, @host)
GO

--6 i) Link publication to my thesis.
GO
CREATE PROC linkPubThesis
@PubID int,
@thesisSerialNo int
AS
INSERT INTO ThesisHasPublication(serialNo, pubid) VALUES (@thesisSerialNo, @PubID)
GO







GO
CREATE PROC listExaminerData
@ID INT,
@success BIT OUTPUT
AS
IF(NOT EXISTS((SELECT T.title AS 'Thesis Title', S.name AS 'Supervisor', GS.firstName + ' ' + GS.lastName AS 'Student Name'
				FROM Defense D INNER JOIN ExaminerEvaluateDefense EED ON D.date = EED.date AND D.serialNumber = EED.serialNo
							   INNER JOIN Examiner E ON E.id = EED.examinerId
							   INNER JOIN Thesis T ON T.serialNumber = D.serialNumber
							   INNER JOIN GUCianStudentRegisterThesis GST ON GST.serial_no = T.serialNumber
							   INNER JOIN Supervisor S ON S.id = GST.supid
							   INNER JOIN GucianStudent GS ON GS.id = GST.sid
				WHERE E.id = @ID AND D.date < CURRENT_TIMESTAMP)
				UNION
				(SELECT T.title AS 'Thesis Title', S.name AS 'Supervisor', NGS.firstName + ' ' + NGS.lastName AS 'Student Name'
				FROM Defense D INNER JOIN ExaminerEvaluateDefense EED ON D.date = EED.date AND D.serialNumber = EED.serialNo
							   INNER JOIN Examiner E ON E.id = EED.examinerId
							   INNER JOIN Thesis T ON T.serialNumber = D.serialNumber
							   INNER JOIN NonGUCianStudentRegisterThesis NGST ON NGST.serial_no = T.serialNumber
							   INNER JOIN Supervisor S ON S.id = NGST.supid
							   INNER JOIN NonGucianStudent NGS ON NGS.id = NGST.sid
				WHERE E.id = @ID AND D.date < CURRENT_TIMESTAMP)))
	SET @success = '0'
ELSE
	BEGIN
		SET @success = '1'
		(SELECT T.title AS 'Thesis Title', S.name AS 'Supervisor', GS.firstName + ' ' + GS.lastName AS 'Student Name'
		FROM Defense D INNER JOIN ExaminerEvaluateDefense EED ON D.date = EED.date AND D.serialNumber = EED.serialNo
					   INNER JOIN Examiner E ON E.id = EED.examinerId
					   INNER JOIN Thesis T ON T.serialNumber = D.serialNumber
					   INNER JOIN GUCianStudentRegisterThesis GST ON GST.serial_no = T.serialNumber
					   INNER JOIN Supervisor S ON S.id = GST.supid
					   INNER JOIN GucianStudent GS ON GS.id = GST.sid
		WHERE E.id = @ID AND D.date < CURRENT_TIMESTAMP)
		UNION
		(SELECT T.title AS 'Thesis Title', S.name AS 'Supervisor', NGS.firstName + ' ' + NGS.lastName AS 'Student Name'
		FROM Defense D INNER JOIN ExaminerEvaluateDefense EED ON D.date = EED.date AND D.serialNumber = EED.serialNo
					   INNER JOIN Examiner E ON E.id = EED.examinerId
					   INNER JOIN Thesis T ON T.serialNumber = D.serialNumber
					   INNER JOIN NonGUCianStudentRegisterThesis NGST ON NGST.serial_no = T.serialNumber
					   INNER JOIN Supervisor S ON S.id = NGST.supid
					   INNER JOIN NonGucianStudent NGS ON NGS.id = NGST.sid
		WHERE E.id = @ID AND D.date < CURRENT_TIMESTAMP)
	END
RETURN @success
GO


GO
CREATE PROC editExaminer
@ID INT,
@name VARCHAR(20),
@fieldOfWork VARCHAR(100)
AS
UPDATE Examiner
SET name = @name, fieldOfWork = @fieldOfWork
WHERE id = @ID
GO



GO
CREATE PROC searchThesis
@keyword VARCHAR(100),
@success BIT OUTPUT
AS
IF(NOT EXISTS(SELECT *
	FROM Thesis
	WHERE title LIKE '%'+@keyword+'%'))
	SET @success = '0'
ELSE IF(@keyword = '')
	SET @success = '0'
ELSE
BEGIN
	SET @success = '1'
	SELECT *
	FROM Thesis
	WHERE title LIKE '%'+@keyword+'%'
END
RETURN @success
GO



GO
create proc getID
@email varchar(50),
@password varchar(50),
@id int output 
AS
select @id= id 
from PostGradUser
where email=@email AND password=@password 
return @id
Go

GO
CREATE PROC getLoginType     
@id INT,     
@type INT OUTPUT     
AS     
IF(EXISTS(SELECT *         
		  FROM GucianStudent        
		  WHERE id = @id))     
BEGIN         
	SET @type = 1     
END     
IF(EXISTS(SELECT *         
		  FROM NonGucianStudent         
		  WHERE id = @id))    
BEGIN         
	SET @type = 2    
END     
IF(EXISTS(SELECT *         
		  FROM Supervisor         
		  WHERE id = @id))     
BEGIN         
	SET @type = 3     
END     
IF(EXISTS(SELECT *         
		  FROM Examiner         
		  WHERE id = @id))     
BEGIN         
	SET @type = 5     
END     
IF(EXISTS(SELECT *         
		  FROM Admin        
		  WHERE id = @id))     
BEGIN         
	SET @type = 4    
END
GO

GO
CREATE PROC AddDefenseGrade
@id INT,
@ThesisSerialNo INT , 
@DefenseDate DATETIME , 
@grade DECIMAL(4,2),
@success BIT OUTPUT
AS
IF(EXISTS(SELECT *
		  FROM Defense D INNER JOIN ExaminerEvaluateDefense EED ON D.date = EED.date 
													   AND D.serialNumber = EED.serialNo
		  WHERE EED.examinerId = @id AND EED.serialNo = @ThesisSerialNo AND D.date = @DefenseDate))
	BEGIN
		SET @success = '1' 
		UPDATE Defense
		SET grade = @grade
		WHERE serialNumber = @ThesisSerialNo AND date = @DefenseDate
	END
ELSE
	SET @success = '0'
RETURN @success
GO

GO
CREATE PROC AddCommentsGrade
@id INT,
@ThesisSerialNo INT , 
@DefenseDate DATETIME , 
@comments varchar(300),
@success BIT OUTPUT
AS
IF(EXISTS(SELECT *
		  FROM Defense D INNER JOIN ExaminerEvaluateDefense EED ON D.date = EED.date 
													   AND D.serialNumber = EED.serialNo
		  WHERE EED.examinerId = @id AND EED.serialNo = @ThesisSerialNo AND D.date = @DefenseDate))
	BEGIN
		SET @success = '1' 
		UPDATE ExaminerEvaluateDefense
		SET comment = @comments
		WHERE serialNo = @ThesisSerialNo AND date = @DefenseDate
	END
ELSE
	SET @success = '0'
RETURN @success
GO



--extra procedures
--1		
go
create proc createExaminer
@first_name varchar(20),
@last_name varchar(20),
@fieldOfWork varchar(20),
@isNational bit,
@email varchar(20),
@password varchar(20)
AS
declare @ExaminerID int
INSERT  INTO PostGradUser (email, password)
VALUES (@email, @password)
set @ExaminerID=scope_identity()
INSERT  INTO Examiner (id,name,fieldOfWork,isNational) 
VALUES (@ExaminerID,@first_name + ' ' + @last_name,@fieldOfWork,@isNational )
GO

--4
GO
create proc getLastEval
@thesisSerialNo int,
@bool int output
AS
Declare @maxDate Date
Declare @evaluation int 
IF(exists(SELECT thesisSerialNumber from GUCianProgressReport where thesisSerialNumber=@ThesisSerialNo))
BEGIN
SELECT @maxDate=max(date)
from GUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo

SELECT	@evaluation=eval 
from GUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo  AND  date=@maxdate

IF(@evaluation=0)
BEGIN
set @bool=1
END
Else
BEgin
set @bool=0
ENd
END
IF(exists(SELECT thesisSerialNumber from NonGUCianProgressReport where thesisSerialNumber=@ThesisSerialNo))
BEGIN
SELECT @maxDate=max(date)
from NonGUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo

SELECT	@evaluation=eval 
from NonGUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo  AND  @maxDate= date 

IF(@evaluation=0)
BEGIN
set @bool=1;
END
Else
BEgin
set @bool=0
ENd
END
return @bool

--5 
go
create proc checkThesisValid
@thesisSerialNo int,
@bool int output
AS
if(exists(select * from Thesis where Thesis.serialNumber=@thesisSerialNo))
begin
set @bool=1;
end
else
begin 
set @bool=0
end 
return @bool

--6
go
create proc checkProgressNoValid
@progress int,
@bool int output
AS
if(exists(select * from GUCianProgressReport where no=@progress))
begin
set @bool=1;
end
else
begin
if(exists(select* from NonGucianProgressReport where no=@progress))
begin
set @bool=1;
end
else
begin
set @bool=0;
end
end
return @bool;

--7
go
create proc checkifstudent
@progress int,
@supid int,
@bool int output
AS
if(exists(select* from GUCianProgressReport where no=@progress and supid=@supid))
begin
set @bool= 1
end
else
begin
if(exists(select* from NonGucianProgressReport where no =@progress and supid=@supid))
begin
set @bool=1
end
else
begin
set @bool =0
end
end
return @bool
--8
GO
CREATE PROC AddDefenseGuciantwo
@ThesisSerialNo INT, 
@DefenseDate DATETIME, 
@DefenseLocation VARCHAR(15)
AS
INSERT INTO Defense(serialNumber, date, location)
VALUES(@ThesisSerialNo, @DefenseDate, @DefenseLocation)
UPDATE Thesis
SET defenseDate = @DefenseDate
WHERE serialNumber = @ThesisSerialNo
--9
GO
Create Proc CheckIFDEF
@ThesisSerialNo INT,
@bool int output
AS
if(exists(select* from Defense where serialNumber=@ThesisSerialNo))
Begin
set @bool=1
end
else
begin
set @bool=0
end
return @bool

--10
go
create proc ThesisBelongs
@ThesisSerialNo INT,
@bool int output
AS
if(exists(Select* from GUCianStudentRegisterThesis where serial_no=@ThesisSerialNo))
begin 
set @bool =1
end
else
begin
if(exists(select* from NonGUCianStudentRegisterThesis where serial_no=@ThesisSerialNo))
begin
set @bool =0
end
else
begin
set @bool=2
end 
end
return @bool

--11
go
CREATE PROC AddDefenseNonGuciantwo
@ThesisSerialNo INT, 
@DefenseDate DATETIME, 
@DefenseLocation VARCHAR(15)
AS
IF(50 < ALL(SELECT ngts.grade
		FROM NonGUCianStudentRegisterThesis ngrt
        INNER JOIN NonGucianStudentTakeCourse ngts ON ngrt.sid = ngts.sid
        WHERE ngrt.serial_no = @ThesisSerialNo))
    BEGIN
        INSERT INTO Defense(serialNumber, date, location)
        VALUES(@ThesisSerialNo, @DefenseDate, @DefenseLocation)
        UPDATE Thesis
        SET defenseDate = @DefenseDate
        WHERE serialNumber = @ThesisSerialNo
END
--12
GO
create proc checkAllCourses
@ThesisSerialNo INT,
@bool int output
As
IF(50 < ALL(SELECT ngts.grade
		FROM NonGUCianStudentRegisterThesis ngrt
        INNER JOIN NonGucianStudentTakeCourse ngts ON ngrt.sid = ngts.sid
        WHERE ngrt.serial_no = @ThesisSerialNo))
Begin
set @bool = 1
ENd
else
begin
Set @bool =0
end
return @bool
--13
GO
create proc defDate
@ThesisSerialNo INT,
@DefDate Datetime output
AS
select @DefDate=D.date
from Defense D
where D.serialNumber=@ThesisSerialNo

--14 
go
create proc checkValidStudent
@studentid int ,
@bool int output
AS 
if(exists( select* from GucianStudent where id=@studentid))
begin
set @bool =1
end
else
begin
if(exists( select * from NonGucianStudent where id=@studentid))
begin
set @bool=1
end
else
begin
set @bool =0
end
end
return @bool


go
create proc checkifThesisMyStudent
@ThesisSerialNo int,
@supid int,
@bool int output
AS
if(exists(select* from GUCianStudentRegisterThesis where serial_no=@ThesisSerialNo and supid=@supid))
begin
set @bool= 1
end
else
begin
if(exists(select* from NonGUCianStudentRegisterThesis where serial_no =@ThesisSerialNo and supid=@supid))
begin
set @bool=1
end
else
begin
set @bool =0
end
end
return @bool


-----------------------------Mostafa 
Go
CREATE PROC mythesis  
@ID int
AS
if(exists(select * From GucianStudent where id=@ID))
BEGIN
Select T.*
from Thesis T inner join GUCianStudentRegisterThesis GRT on GRT.serial_no = T.serialNumber INNER JOIN GucianStudent G ON G.id = GRT.sid
WHERE g.id = @ID
END
ELSE
BEGIN
Select T.*
from Thesis T inner join NonGUCianStudentRegisterThesis NGRT on NGRT.serial_no = T.serialNumber INNER JOIN NonGucianStudent G ON G.id = NGRT.sid
WHERE g.id = @ID
END
go

create Proc ongoingthesis
@thesisSerialNO int,
@success bit Output
AS
IF(EXISTS(SELECT *
        FROM  Thesis T
        WHERE T.serialNumber = @thesisSerialNO AND T.endDate > CURRENT_TIMESTAMP AND T.startDate < CURRENT_TIMESTAMP  ))
	BEGIN
	set @success = 1
	end
Else
	begin
	set @success = 0
	end
return @success;



go
create proc getMyThesis
@StudentID int,
@thesisSerialNO int,
@myThesis bit output
AS
if(exists(select * from GUCianStudentRegisterThesis where sid=@studentID and serial_no = @thesisSerialNO ))
BEGIN
set @myThesis = 1
END
ELse if(exists(select * from NonGUCianStudentRegisterThesis where sid=@StudentID and serial_no = @thesisSerialNO))
begin
set @myThesis= 1
end
else
	begin
	set @myThesis= 0;
	end
return @myThesis


go
create Proc ifFoundLink
@thesisSerialNO int,
@PubID  int,
@found bit Output
AS
IF(EXISTS(SELECT *
        FROM  ThesisHasPublication T
        WHERE T.serialNo = @thesisSerialNO AND T.pubid = @PubID ))
	BEGIN
	set @found = 1
	end
Else
	begin
	set @found = 0
	end
return @found;


go
create Proc ifFoundmobile
@ID int, 
@mobile_number varchar(20),
@found bit output
AS
IF(EXISTS(SELECT id FROM GucianStudent WHERE id = @ID))
	begin
	IF(EXISTS(SELECT * FROM GucStudentPhoneNumber WHERE id = @ID and phone = @mobile_number ))
		begin
		set @found = 1
		end
	else
		begin
		set @found = 0
		end
	end
ELSE IF(EXISTS(SELECT id FROM NonGucianStudent WHERE id = @ID))
	begin
	IF(EXISTS(SELECT * FROM NonGucStudentPhoneNumber WHERE id = @ID and phone = @mobile_number ))
		begin
		set @found = 1
		end
	else
		begin
		set @found = 0
		end
	end
return @found;


go
create proc getMyPublicationNo
@title varchar(50),
@host varchar(50),
@place varchar(50),
@myPublication int output
AS
select @myPublication= p.id from Publication P where P.host = @host and P.title = @title And p.place = @place
return @myPublication;



go

create proc getMyProgressReportNo
@thesisSerialNo int,
@progressReportDate date,
@MyProgressReportNo int output
AS
if (exists(select * from GUCianProgressReport P where P.date = @progressReportDate AND P.thesisSerialNumber = @thesisSerialNo))
BEGIN
select @MyProgressReportNo= p.no from GUCianProgressReport P where P.date = @progressReportDate AND P.thesisSerialNumber = @thesisSerialNo
END
ELSE IF  (exists(select * from GUCianProgressReport P where P.date = @progressReportDate AND P.thesisSerialNumber = @thesisSerialNo))
BEGIN
select @MyProgressReportNo= p.no from GUCianProgressReport P where P.date = @progressReportDate AND P.thesisSerialNumber = @thesisSerialNo
END
return @MyProgressReportNo;


go

create proc IfMyProgressreportExists
@thesisSerialNo int,
@MyProgressReportNo int,
@Myexists bit output
AS
if (exists(select * from GUCianProgressReport P where p.no= @MyProgressReportNo AND P.thesisSerialNumber = @thesisSerialNo))
	BEGIN
	set @Myexists = 1
	END
ELSE IF  (exists(select * from GUCianProgressReport P where p.no= @MyProgressReportNo AND P.thesisSerialNumber = @thesisSerialNo))
	BEGIN
	set @Myexists = 1
	end
Else
	begin
	set @Myexists = 0
	end
return @Myexists;



go


go
Create proc userLogin
@id int,
@password varchar(20),
@success bit output
as
begin
if exists(
select ID,password
from PostGradUser
where id=@id and password=@password)
set @success =1
else
set @success=0
end
return @success
go


--largest Payment Id
create proc largestPayment
@largest int output
as
select @largest=max(id) from Payment
go
--largest Thesis serial
create proc largestSerial
@maximum int output
as
select @maximum=max(serialNumber) from Thesis





--					                     INSERTIONS

SET DATEFORMAT dmy 
--                                      Thesis Payment

INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 1
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 2
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 3
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 4
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 5
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 6
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 7
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 8
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (250000, 5, 0.167)--thesis 9
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (250000, 5, 0.167)--thesis 10
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (250000, 5, 0.167)--thesis 11
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (250000, 5, 0.167)--thesis 12
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (250000, 5, 0.167)--thesis 13
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 14
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (120000, 2, 0.167)--thesis 15


--           						   Course Payments

INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (6000, 1, 0.167)  --16
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (4000, 1, 0.167)  --17
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (6000, 1, 0.111)  --18
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (4000, 1, 0.111)  --19
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (6000, 1, 0.111)  --20
INSERT INTO Payment (amount, no_Installments, fundPercentage) VALUES (4000, 1, 0.111)  --21


--                                       INSTALLMENT


--		                             Thesis Installments

INSERT INTO Installment (date, paymentId, amount, done) VALUES ('12/11/2020', 1, 60000, '1')--1 for thesis 1 
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('12/11/2021', 1, 60000, '1')--2 for thesis 1
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('23/2/2021', 2, 60000, '1')--3 for thesis 2
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('23/2/2022', 2, 60000, '0')--4 for thesis 2
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/1/2015', 3, 60000, '1')--5 for thesis 3
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/1/2016', 3, 60000, '1')--6 for thesis 3
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('24/3/2017', 4, 60000, '1')--7 for thesis 4
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('24/3/2018', 4, 60000, '1')--8 for thesis 4
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('6/7/2019', 5, 60000, '1')--9 for thesis 5
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('6/7/2020', 5, 60000, '1')--10 for thesis 5
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('29/10/2021', 6, 60000, '0')--11 for thesis 6
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('29/10/2022', 6, 60000, '1')--12 for thesis 6
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('6/9/2015', 7, 60000, '1')--13 for thesis 7
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('6/9/2016', 7, 60000, '1')--14 for thesis 7
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('17/7/2019', 8, 60000, '1')--15 for thesis 8
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('17/7/2020', 8, 60000, '1')--16 for thesis 8
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('9/5/2017', 9, 50000, '1')--17 for thesis 9
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('9/5/2018', 9, 50000, '1')--18 for thesis 9
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('9/5/2019', 9, 50000, '1')--19 for thesis 9
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('9/5/2020', 9, 50000, '1')--20 for thesis 9
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('9/5/2021', 9, 50000, '1')--21 for thesis 9
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/3/2015', 10, 50000, '1')--22 for thesis 10
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/3/2016', 10, 50000, '1')--23 for thesis 10
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/3/2017', 10, 50000, '1')--24 for thesis 10
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/3/2018', 10, 50000, '1')--25 for thesis 10
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('15/3/2019', 10, 50000, '1')--26 for thesis 10
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/6/2016', 11, 50000, '1')--27 for thesis 11
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/6/2017', 11, 50000, '1')--28 for thesis 11
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/6/2018', 11, 50000, '1')--29 for thesis 11
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/6/2019', 11, 50000, '1')--30 for thesis 11
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/6/2020', 11, 50000, '1')--31 for thesis 11
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('25/1/2015', 12, 50000, '1')--32 for thesis 12
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('25/1/2016', 12, 50000, '1')--33 for thesis 12
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('25/1/2017', 12, 50000, '1')--34 for thesis 12
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('25/1/2018', 12, 50000, '1')--35 for thesis 12
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('25/1/2019', 12, 50000, '1')--36 for thesis 12
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/7/2012', 13, 50000, '1')--37 for thesis 13
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/7/2013', 13, 50000, '1')--38 for thesis 13
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/7/2014', 13, 50000, '1')--39 for thesis 13
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/7/2015', 13, 50000, '1')--40 for thesis 13
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/7/2016', 13, 50000, '1')--41 for thesis 13
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('28/4/2021', 14, 60000, '1')--42 for thesis 14
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('28/4/2022', 14, 60000, '0')--43 for thesis 14
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/3/2012', 15, 60000, '1')--44 for thesis 15
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('4/3/2013', 15, 60000, '1')--45 for thesis 15


--                                    Course Installments

INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/12/2019',16,6000,'1') --46
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/1/2020',17,4000,'1')  --47
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('28/2/2021',18,6000,'1')  --48
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/1/2022',19,4000,'0')  --49
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('26/2/2021',20,6000,'1')  --50
INSERT INTO Installment (date, paymentId, amount, done) VALUES ('30/3/2021',21,4000,'1')  --51


--                                      GUCians


INSERT INTO PostGradUser(email,password) --1
VALUES ('omarmoataz123@gmail.com','Omar123')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (1,'Omar','Moataz','Masters','Computer Science','NASR CITY STREET 1 Villa 13',1.22) 

INSERT INTO PostGradUser(email,password) --2
VALUES ('Alymoataz123@hotmail.com','Aly123')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (2,'Aly','Moataz','Masters','Computer Science','rehab street 19 building 2',1.3) 

INSERT INTO PostGradUser(email,password) --3
VALUES ('hamzamohamed@gmail.com','H_abcdefg123')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (3,'Hamza','Mohamed','Masters','Applied Arts','Masr el gedida street 12',1.9) 

INSERT INTO PostGradUser(email,password) --4
VALUES ('radwan1921@gmail.com','rodo2001')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (4,'Radwan','Waleed','Masters','Applied Arts','Sheraton street 1 building 5',1.0) 

INSERT INTO PostGradUser(email,password) --5
VALUES ('haythamahmed@hotmail.com','aho1956')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (5,'Haytham','Ahmed','Masters','Law','Fifth Settlement street 15 ',0.7) 

INSERT INTO PostGradUser(email,password) --6
VALUES ('sarahamdy@gmail.com','s123abc')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (6,'Sara','hamdy','Masters','Law','Madinty street 12 building 11',2.0) 

INSERT INTO PostGradUser(email,password) --7
VALUES ('yaramohamed@hotmail.com','yara123abc')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (7,'yara','mohamed','Masters','Civil Engineering','Nasr city street 13 district 2 building 11',1.1) 

INSERT INTO PostGradUser(email,password) --8
VALUES ('yassermohamed@hotmail.com','yasser123abc')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (8,'yasser','mohamed','Masters','Pharmacy','Nasr city street 12 villa 11',2.2) 

INSERT INTO PostGradUser(email,password) --9
VALUES ('yasminmaher@hotmail.com','yaso123abc')
INSERT INTO GucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES (9,'yasmin','maher','PHD','Computer Science','Fifth settlement street 13 villa 99',2.3) 


--                                     Non GUCians


INSERT INTO PostGradUser(email,password) --10
VALUES ('marwanmagdy@gmail.com','MAro123')
INSERT INTO NonGucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES(10,'Marwan','Magdy','PHD','Applied Arts','Nasr City Street 123 villa 155',0.8)

INSERT INTO PostGradUser(email,password) --11
VALUES ('youssefmagdy@hotmail.com','youabc123')
INSERT INTO NonGucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES(11,'Youssef','Magdy','PHD','Law','Rehab District 15 street 12 villa 11',1.2)

INSERT INTO PostGradUser(email,password) --12
VALUES ('tasneemkhaled@hotmail.com','tasneem_g123')
INSERT INTO NonGucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES(12,'tasneem','khaled','PHD','Civil Engineering','Madinty district 1 street 1 villa 123',1.8)

INSERT INTO PostGradUser(email,password) --13
VALUES ('OmarMohamed@gmail.com','omar2001')
INSERT INTO NonGucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES(13,'Omar','Mohamed','PHD','Pharmacy','Nasr City building 12345 ',0.88)

INSERT INTO PostGradUser(email,password) --14
VALUES ('kareemmohamed@hotmail.com','kimo_123')
INSERT INTO NonGucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES(14,'kareem','mohamed','Masters','Civil Engineering','Rehab 1 street 123456 building 123 ',1.1)

INSERT INTO PostGradUser(email,password) --15
VALUES ('salmafarouk@gmail.com','sara_123abc')
INSERT INTO NonGucianStudent(id,firstName,lastName,type,faculty,address,gpa)
VALUES(15,'Salma','Farouk','Masters','Pharmacy','Fifth Settlement street 105 villa 123',1.4)



--                                         Admins

INSERT INTO PostGradUser(email,password) --16
VALUES ('Meriamamgad@gmail.com','M_ADmin123')
INSERT INTO admin(id)
VALUES (16)

INSERT INTO PostGradUser(email,password) --17
VALUES ('mahermagdy@gmail.com','MAher_admin123')
INSERT INTO admin (id)
VALUES(17)


--                                       Supervisors


INSERT INTO PostGradUser(email,password) --18
VALUES ('omarmagdy@gmail.com','omar_super123')
INSERT INTO supervisor(id,name,faculty)
VALUES(18,'Omar Magdy','Computer Science')

INSERT INTO PostGradUser(email,password) --19
VALUES ('saramagdy@gmail.com','sara_magdy123')
INSERT INTO supervisor(id,name,faculty)
VALUES(19,'Sara Magdy','Applied Arts')

INSERT INTO PostGradUser(email,password) --20
VALUES ('tamaraamgad@gmail.com','T_superabc')
INSERT INTO supervisor(id,name,faculty)
VALUES(20,'Tamara Amgad','Pharmacy')

INSERT INTO PostGradUser(email,password) --21
VALUES ('MariamSherif@gmail.com','Mar_superabc2342')
INSERT INTO supervisor(id,name,faculty)
VALUES(21,'Mariam sherif ','Civil Engineering')

INSERT INTO PostGradUser(email,password) --22
VALUES ('Habibakhaled@gmail.com','Hab_super1234')
INSERT INTO supervisor(id,name,faculty)
VALUES(22,'Habiba Khaled','Law')


--                                         Examiners


INSERT INTO PostGradUser(email,password) --23
VALUES ('DavidFarouk@hotmail.com','D_exam123')
INSERT INTO Examiner (id, name, fieldOfWork, isNational)
VALUES(23,'David Farouk', 'Engineering','0')

INSERT INTO PostGradUser(email,password) --24
VALUES ('BasselKareem@gmail.com','bassel_magdy123')
INSERT INTO Examiner (id, name, fieldOfWork, isNational)
VALUES(24,'Bassel Kareem', 'Science','1')


--                                          Course


INSERT INTO Course (fees,creditHours,code) -- Applied Arts 1
VALUES(6000,6,'CI301')
INSERT INTO Course (fees,creditHours,code) -- Civil 2
VALUES(6000,6,'CIS602')
INSERT INTO Course (fees,creditHours,code) -- Computer Science 3
VALUES(4000,4,'CSEN503')
INSERT INTO Course (fees,creditHours,code) -- Law 4
VALUES(4000,4,'CILA')
INSERT INTO Course (fees,creditHours,code) -- Pharmacy 5
VALUES(4000,4,'PHBC621')


--                               Non Gucian Student Pay For Course


INSERT INTO NonGucianStudentPayForCourse (sid, paymentNo, cid) VALUES (10, 16, 1) -- Student 10 pays for course 1 with payment 16
INSERT INTO NonGucianStudentPayForCourse (sid, paymentNo, cid) VALUES (11, 17, 4) -- Student 11 pays for course 4 with payment 17
INSERT INTO NonGucianStudentPayForCourse (sid, paymentNo, cid) VALUES (12, 18, 2) -- Student 11 pays for course 2 with payment 18
INSERT INTO NonGucianStudentPayForCourse (sid, paymentNo, cid) VALUES (13, 19, 5) -- Student 11 pays for course 5 with payment 19
INSERT INTO NonGucianStudentPayForCourse (sid, paymentNo, cid) VALUES (14, 20, 2) -- Student 12 pays for course 2 with payment 20
INSERT INTO NonGucianStudentPayForCourse (sid, paymentNo, cid) VALUES (15, 21, 5) -- Student 12 pays for course 5 with payment 21


--                                Non Gucian Student Take Course


INSERT INTO NonGucianStudentTakeCourse (sid, cid,grade) VALUES (10, 1,95) -- Student 10 takes Course 1 
INSERT INTO NonGucianStudentTakeCourse (sid, cid,grade) VALUES (11, 4,70) -- Student 11 takes Course 4 
INSERT INTO NonGucianStudentTakeCourse (sid, cid,grade) VALUES (12, 2,40) -- Student 12 takes Course 2
INSERT INTO NonGucianStudentTakeCourse (sid, cid) VALUES (13, 5)		  -- Student 13 takes Course 5
INSERT INTO NonGucianStudentTakeCourse (sid, cid,grade) VALUES (14, 2,87) -- Student 14 takes Course 2
INSERT INTO NonGucianStudentTakeCourse (sid, cid,grade) VALUES (15, 5,76) -- Student 15 takes Course 5


--                                          Thesis


insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension) --1
values('Computer Science','Masters','Low power interconnected embedded devices for IoT','12/11/2020','12/11/2022','1/11/2022',1,0)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension) --2
values('Computer Science', 'Masters','Cyber-physical security of an electric microgrid','23/2/2021','23/2/2023','11/1/2023',2,0)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --3
values('Applied Arts','Masters','PHOTO PUBLICITY OF TOURISM IN ENUGU STATE','15/1/2015','15/1/2017','1/1/2017',3,0,97)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --4
values('Applied Arts','Masters','SUPPLICATION A CASE STUDY OF FORMS IN WOOD CARVING','24/3/2017','24/3/2019','1/3/2019',4,0,90)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --5
values('Law','Masters','Digital Matchmaking and the Law','6/7/2019','6/7/2021','28/6/2021',5,0,80)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension) --6
values('Law','Masters','Rights, autonomy and pregnancy','29/10/2021','29/10/2023','4/10/2023',6,0)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --7
values('Civil Engineering','Masters','Effects of Truck Impacts on Bridge Piers','6/9/2015','6/9/2017','25/8/2017',7,0,75)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --8
values('Pharmacy','Masters','IMPLICATIONS OF THE COST OF END OF LIFE CARE','17/7/2019','17/7/2021','1/7/2021',8,0,99)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension) --9
values('Computer Science', 'PHD', 'MACHINE LEARNING IN MEDICAL IMAGE ANALYSIS','9/5/2017','9/5/2022','25/4/2022',9,0)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --10
values('Applied Arts','PHD','ART FORMS ON OPOTO FESTIVAL IN ENUGWU- AGIDI','15/3/2015','15/3/2020','1/3/2020',10,1,100)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --11
values('Law','PHD','The action for injunction in EU consumer law','30/6/2016','30/6/2021','15/6/2021',11,1,92)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --12
values('Civil Engineering','PHD','Settlement Analysis Of Stabilized Sand Bed','25/1/2015','25/1/2020','10/1/2020',12,2,91)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --13
values('Pharmacy','PHD','Analyzing natural drugs for cancer','4/7/2012','4/7/2017','25/6/2017',13,0,98)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension) --14
values('Civil Engineering','Masters','Analysis and Design of Reinforced Soil Wall','28/4/2021','28/4/2023','5/4/2023',14,0)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,payment_id,noExtension,grade) --15
values('Pharmacy','Masters','Factor Influencing Postpartum Contraception Uptake','4/3/2012','4/3/2014','25/2/2014',15,0,78)

insert into Thesis (field,type,title,startDate,endDate,defenseDate,noExtension) --16
values('Computer Science','Masters','Data Mining','4/6/2020','4/6/2022','25/5/2022',0)



--                                    Gucian Register Thesis


INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --1
VALUES (1,18,1)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --2
VALUES (2,18,2)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --3
VALUES (3,19,3)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --4
VALUES (4,19,4)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --5
VALUES (5,22,5)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --6
VALUES (6,22,6)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --7
VALUES (7,21,7)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --8
VALUES (8,20,8)
INSERT INTO GUCianStudentRegisterThesis(sid, supid, serial_no) --9
VALUES (9,18,9)


--                                   Non Gucian register thesis


INSERT INTO NonGUCianStudentRegisterThesis(sid, supid, serial_no) --10
VALUES (10,19,10)
INSERT INTO NonGUCianStudentRegisterThesis(sid, supid, serial_no) --11
VALUES (11,22,11)
INSERT INTO NonGUCianStudentRegisterThesis(sid, supid, serial_no) --12
VALUES (12,21,12)
INSERT INTO NonGUCianStudentRegisterThesis(sid, supid, serial_no) --13
VALUES (13,20,13)
INSERT INTO NonGUCianStudentRegisterThesis(sid, supid, serial_no) --14
VALUES (14,21,14)
INSERT INTO NonGUCianStudentRegisterThesis(sid, supid, serial_no) --15
VALUES (15,20,15)

--                                   GUCian Progress Report

INSERT INTO GUCianProgressReport (sid, date, state, thesisSerialNumber, supid, description) -- Omar Moataz --> Algorithms & Architectures
VALUES (1, '13/9/2021', 50, 1, 18, 'Finished Algorithms')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Aly Moataz --> Artificial Intelligence
VALUES (2, '7/1/2023', 0, 84, 2, 18, 'Done with software')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Hamza Mohamed --> A Thematic Analysis of Ben Ibebe's Paintings
VALUES (3, '26/6/2016', 92, 83, 3, 19, 'Only Details is left')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Radwan Waleed --> Supplication
VALUES (4,'14/4/2018', 69, 93, 4, 19, 'Finished all calculactions')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Haytham Ahmed --> Jury Directions
VALUES (5, '29/3/2021', 67, 90, 5, 22, 'Studied some laws')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Sara Hamdy --> Artificial Intelligence
VALUES (6, '29/10/2022', 92, 67, 6, 22, 'Parts designed')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Yara mohamed --> Settlement Analysis of a Foundation in Sandy Ground
VALUES (7, '6/9/2016', 85, 79, 7, 21, 'Simulation left')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Yasser mohamed --> Electronic Nicotine Delivery System
VALUES (8, '19/6/2020', 76, 81, 8, 20, 'Connecting everything')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Yasmin Maher 1 --> A Convex Optimisation Approach to Optimal Control in Queueing Systems
VALUES (9, '5/3/2020', 98, 30, 9, 18, 'Simulation done, implementation still required')
INSERT INTO GUCianProgressReport (sid, date, eval, state, thesisSerialNumber, supid, description) -- Yasmin Maher 2 --> A Convex Optimisation Approach to Optimal Control in Queueing Systems
VALUES (9, '5/3/2021', 95, 89, 9, 18, 'Implementation in progress')



--                                 Non GUCian Progress Report



INSERT INTO NonGUCianProgressReport (sid, date, thesisSerialNumber, supid, description, state) -- Kareem Mohamed --> Numerical Analysis Of Excavation Movements’ Stresses And Deformations
VALUES (14,'30/12/2021', 14,21, 'Implemented all movements',80)
INSERT INTO NonGUCianProgressReport (sid, date, thesisSerialNumber, supid, description ,eval, state) -- Salma Farouk --> Factors Influencing Postpartum Contraception Uptake
VALUES (15,'25/6/2013', 15,20, 'Wrapping up',80,96)

---                                         Add a Defence 


INSERT INTO Defense (serialNumber,date,location) --1
VALUES(1,'1/11/2022','Lecture Hall 2')

INSERT INTO Defense (serialNumber,date,location,grade) --3
VALUES(3,'1/1/2017','C5 211',97)
INSERT INTO Defense (serialNumber,date,location,grade) --4
VALUES(4,'1/3/2019','D4 209',92)
INSERT INTO Defense (serialNumber,date,location,grade) --5
VALUES(5,'28/6/2021','Lecture Hall 12',88)
INSERT INTO Defense (serialNumber,date,location) --6
VALUES(6,'4/10/2023','Lecture 18')
INSERT INTO Defense (serialNumber,date,location,grade) --7
VALUES(7,'25/8/2017','Lecture Hall 16',83)
INSERT INTO Defense (serialNumber,date,location,grade) --8
VALUES(8,'1/7/2021','Lecture Hall 14',95)
INSERT INTO Defense (serialNumber,date,location) --9
VALUES(9,'25/4/2022','D4 101')
INSERT INTO Defense (serialNumber,date,location,grade) --10
VALUES(10,'1/3/2020','C7 212',87)

INSERT INTO Defense (serialNumber,date,location,grade) --12
VALUES(12,'10/1/2020','Lecture Hall 17',93)
INSERT INTO Defense (serialNumber,date,location,grade) --13
VALUES(13,'25/6/2017','B2 201',81)
INSERT INTO Defense (serialNumber,date,location) --14
VALUES(14,'5/4/2023','Lecture Hall 3')
INSERT INTO Defense (serialNumber,date,location,grade) --15
VALUES(15,'25/2/2014','Lecture Hall 4',96)


--                                      Add Examiner for a Defence 



INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --3
VALUES('1/1/2017',3,24,'Excellent')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --4
VALUES('1/3/2019',4,23,'very good job')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --5
VALUES('28/6/2021',5,24,'good job')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId) --6
VALUES('4/10/2023',6,23)
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --7
VALUES('25/8/2017',7,24,'needs improvement')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --8
VALUES('1/7/2021',8,23,'excellent work')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId) --9
VALUES('25/4/2022',9,24)
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --10
VALUES('1/3/2020',10,23,'Needs a little bit of work')

INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --12
VALUES('10/1/2020',12,23,'Good work')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --13
VALUES('25/6/2017',13,24,'Needs a bit of work')
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId) --14
VALUES('5/4/2023',14,23)
INSERT INTO ExaminerEvaluateDefense(date,serialNo,examinerId,comment) --15
VALUES('25/2/2014',15,24,'Keep up the good work')

--												ADD PUBLICATION

INSERT INTO Publication( title, date, place, accepted, host) -- Publication 1 has Thesis 10
VALUES ('OPOTO FESTIVAL IN ENUGWU- AGIDI','15/3/2021','H4','1','Balabizo')

INSERT INTO Publication( title, date, place, accepted, host) -- Publication 2 has Thesis 13
VALUES ('relation between drugs and cancer','25/6/2017','H13','1','Shaher')

INSERT INTO Publication( title, date, place, accepted, host) -- Publication 3 has Thesis 15
VALUES ('Influence of Postpartum Contraception Uptake','25/2/2015','H3','0','Salma Tammam')

INSERT INTO ThesisHasPublication(serialNo, pubid)
VALUES (10,1)

INSERT INTO ThesisHasPublication(serialNo, pubid)
VALUES (13,2)

INSERT INTO ThesisHasPublication(serialNo, pubid)
VALUES (15,3)


