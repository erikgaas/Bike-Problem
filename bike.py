import datetime
import numpy as np
from sklearn.ensemble import RandomForestClassifier

file_out = open("train.csv", "r")
labels = file_out.readline()

data = file_out.read()
data = data.split('\n')
data = [i.split(',') for i in data]
file_out.close()


all_dates = [i[0] for i in data]
all_dates = [i.split(' ') for i in all_dates]

day_info = [i[0] for i in all_dates]
day_info = [i.split('-') for i in day_info]

hour_info = [i[1] for i in all_dates]
hour_info = [list(map(int, i.split(':'))) for i in hour_info]
hour_info = list(map(int, [i[0] + (i[1]/60) + (i[2]/(60*60)) for i in hour_info]))

for i in range(len(day_info)):
	for j in range(len(day_info[i])):
		day_info[i][j] = int(day_info[i][j].lstrip('0'))

datetime_objs = [datetime.datetime(i[0], i[1], i[2]) for i in day_info]

#completed year, month, day, weekday
day_info = [day_info[i] + [datetime_objs[i].weekday()] for i in range(len(datetime_objs))]

fin_data = [day_info[i] + [hour_info[i]] + list(map(float, data[i][1:-1])) for i in range(len(data))]
fin_data = [list(map(float, i))[0:13] for i in fin_data]



#sklearn stuff
X = np.array(fin_data)
Y = np.array([int(i[-1]) for i in data])
clf = RandomForestClassifier(n_estimators=20)
clf.fit(X,Y)


def get_data_test(f_name):
	file_out = open(f_name, "r")
	labels = file_out.readline()

	data = file_out.read()
	data = data.split('\n')
	data = [i.split(',') for i in data]



	all_dates = [i[0] for i in data]
	all_dates = [i.split(' ') for i in all_dates]

	day_info = [i[0] for i in all_dates]
	day_info = [i.split('-') for i in day_info]

	hour_info = [i[1] for i in all_dates]
	hour_info = [list(map(int, i.split(':'))) for i in hour_info]
	hour_info = list(map(int, [i[0] + (i[1]/60) + (i[2]/(60*60)) for i in hour_info]))

	for i in range(len(day_info)):
		for j in range(len(day_info[i])):
			day_info[i][j] = int(day_info[i][j].lstrip('0'))

	datetime_objs = [datetime.datetime(i[0], i[1], i[2]) for i in day_info]

	#completed year, month, day, weekday
	day_info = [day_info[i] + [datetime_objs[i].weekday()] for i in range(len(datetime_objs))]

	fin_data = [day_info[i] + [hour_info[i]] + list(map(float, data[i][1:])) for i in range(len(data))]
	return [list(map(float, i)) for i in fin_data], data

test_data, end_data = get_data_test("test.csv")

#print(fin_data[0],Y[0])
#print(fin_data[0], test_data[0])
horrible = clf.predict(test_data)
print(horrible)

output = open("horrible.csv", "w")
output.write("datetime,count\n")
for i in range(len(horrible)):
	output.write(end_data[i][0] + ","+ str(horrible[i]) + "\n")

output.close()