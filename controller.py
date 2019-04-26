import os

import pymysql
from flask import render_template, request, redirect
from flask import Flask
from werkzeug.utils import secure_filename

app = Flask(__name__)

global CurrentUserId

def dbconn():
	return pymysql.connect(host='localhost', user='root', password='1234', db='demo')

@app.route('/')
def home():
	return render_template('home.html')

@app.route('/centralPage')
def central():
	return render_template('central_page.html')

@app.route('/signup')
def Signup():
	return render_template('sign_up.html')

@app.route('/signin')
def Signin():
	return render_template('sign_in.html')

@app.route('/addpassenger')
def AddPassenger():
	return render_template('create_passenger.html')

@app.route('/showpassenger')
def ShowPassenger():
	return render_template('show_passenger.html')

@app.route('/searchonewayflights')
def searchFlights():
	return render_template('search_oneway_flights.html')

@app.route('/checkin')
def checkin():
	return render_template('check_flights_by_name.html')

@app.route('/addUser', methods=['POST','GET'])
def addUser():
	if request.method == 'POST':
		try:

			firstName = request.form['FirstName']
			lastName = request.form['LastName']
			dateOfBirth = request.form['DateOfBirth']
			gender = request.form['Gender']
			country = request.form['Country']
			state = request.form['State']
			city = request.form['City']
			address1 = request.form['Address1']
			address2 = request.form['Address2']
			zipCode = request.form['ZIPCode']
			email = request.form['Email']
			username = request.form['UserName']
			password = request.form['Password']

			conn = dbconn();

			sql = "INSERT INTO demo.usertable (`username`, `password`, `firstName`, `lastName`, `dateOfBirth`, `gender`, `country`, `state`, `city`, `address1`, `address2`, `zipCode`, `email`) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
			cursor = conn.cursor()
			cursor.execute(sql, (username,password, firstName, lastName, dateOfBirth, gender, country, state, city, address1, address2, zipCode, email))
			conn.commit()
			msg= "Account successfully created"
		except Exception as e:
			print(e)
			msg = "Error in creating new account"
			conn.rollback()
		finally:
			return render_template("sign_in.html",msg=msg)
			conn.close()

@app.route('/signIn', methods = ['POST'])
def signIn():
	if request.method == 'POST':
		try:
			entered_username = request.form['entered_username']
			entered_password = request.form['entered_password']
			conn = dbconn();
			sql = "SELECT userId FROM userTable WHERE username = (%s) AND password = (%s)"
			cursor = conn.cursor()
			cursor.execute(sql, (entered_username, entered_password))
			data = cursor.fetchone()
			if data is None:
				msg="Login Failed"
				page="sign_in.html"
			else:
				global CurrentUserId
				CurrentUserId = data[0]
				msg = "Login sucessful"
				page="central_page.html"
		except Exception as e:
			print(e)
			msg = "Error in Logging in"
			conn.rollback()
		finally:
			return render_template(page,msg=msg)
			conn.close()

@app.route('/showPassenger')
def showPassenger():
	global CurrentUserId
	conn = dbconn()
	sql = "CALL showPassengerWithUserId(%s)"
	cursor = conn.cursor()
	cursor.execute(sql, CurrentUserId)
	rows = cursor.fetchall()
	data=[]
	for row in rows:
		temp = [row[0], row[1], row[2], row[3], row[4], row[5]]
		data.append(list(temp))
	conn.close()
	return render_template("show_passenger.html", rows=data)

@app.route('/addPassenger', methods=['POST','GET'])
def addPassenger():
	if request.method =='POST':
		try:
			firstName = request.form['FirstName']
			lastName = request.form['LastName']
			dateOfBirth = request.form['DateOfBirth']
			gender = request.form['Gender']
			country = request.form['Country']
			global CurrentUserId

			conn = dbconn();

			sql = "INSERT INTO passengertable (`firstName`, `lastName`, `dateOfBirth`, `gender`, `Country`, `userId`) VALUES (%s,%s,%s,%s,%s,%s); "
			cursor = conn.cursor()
			cursor.execute(sql, (firstName, lastName, dateOfBirth, gender, country, CurrentUserId))
			conn.commit()
			msg="Passenger Created!"
		except Exception as e:
			print(e)
			msg="Error in Creating New Passenger"
			conn.rollback()
		finally:
			return render_template('central_page.html',msg=msg)
			conn.close()

@app.route('/searchOneWayFlights', methods=['POST','GET'])
def searchOnewayFlights():
	if request.method =='POST':
		try:
			from_ = request.form['From']
			to = request.form['To']
			departureDate = request.form['DepartureDate']
			global CurrentUserId

			conn = dbconn();
			sql = "CALL searchFlights(%s,%s,%s);"
			cursor = conn.cursor()
			cursor.execute(sql,(from_,to,departureDate))
			conn.commit()
			rows=cursor.fetchall()
			data=[]
			for row in rows:
				temp = [row[0], row[1], row[2], row[3], row[4], row[5], row[6]]
				data.append(list(temp))
			msg='Search Complete'
		except Exception as e:
			print(e)
			msg="Error in Searching"
			conn.rollback()
		finally:
			return render_template('search_result_oneway.html',rows=data,msg=msg)
			conn.close()

@app.route('/selectFlights', methods=['POST','GET'])
def selectFlights():
	if request.method == 'POST':
		flightId = request.form['flight_id']
		global CurrentUserId

		conn = dbconn();
		sql = "CALL addFlights(%s,%s)"
		cursor = conn.cursor()
		cursor.execute(sql,(CurrentUserId ,flightId))
		conn.commit()
		msg="Select Sucessful"
		return render_template("central_page.html", msg=msg)

# @app.route('/checkIn', methods=['POST','GET'])
# def checkIn():
# 	if request.method == 'POST':


if __name__ == '__main__':
	app.run(debug=True)