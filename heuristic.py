file_out = open("oldtrain.csv", "r")
labels = file_out.readline()

train_data = file_out.read()
train_data = train_data.split('\n')
train_data = [i.split(',') for i in train_data]
file_out.close()

file_out = open("oldtest.csv", "r")
labels = file_out.readline()

test_data = file_out.read()
test_data = test_data.split('\n')
test_data = [i.split(',') for i in test_data]
file_out.close()

#Real Code

#make dictrionaries
casual = {i[0]:int(i[-3]) for i in train_data}
registered = {i[0]:int(i[-2]) for i in train_data}


def single_digits(num):
	num = str(num)
	if len(num) == 1:
		num = '0' + num
		return num
	else:
		return num

def predict_casual(test_day):
	day = int(test_day[8:10].lstrip('0'))
	measure = [(((day-1)%7) + i*7) + 1 for i in range(0,5)]
	measure_numbers = [i for i in measure if i <=19]
	measure = list(map(single_digits, measure_numbers))

	measure_casuals = []
	for i in range(len(measure)):
		try:
			temp = [casual[ test_day[0:8] + measure[i] + test_day[10:] ] ]
			temp = list(map(int, temp))
			measure_casuals = measure_casuals + temp
		except:
			pass
#measure_casuals = list(map(int, [casual[ test_day[0:8] + measure[i] + test_day[10:] ] for i in range(len(measure))] ))

	slopes = [measure_casuals[i] - measure_casuals[i-1] for i in range(1, len(measure_casuals))]
	if len(slopes) <= 1:
		avg_slope = 1
	else:
		avg_slope = sum(slopes) / len(slopes)

	#result = ((day - measure_numbers[-1])/7 * avg_slope) + measure_casuals[-1]
	result = sum(measure_casuals) / len(measure_casuals)
	result = int(round(result, 0))
	if result > 0 :
		return result
	else:
		return 0


def predict_registered(test_day):
	day = int(test_day[8:10].lstrip('0'))
	measure = [(((day-1)%7) + i*7) + 1 for i in range(0,5)]
	measure_numbers = [i for i in measure if i <=19]
	measure = list(map(single_digits, measure_numbers))

	measure_casuals = []
	for i in range(len(measure)):
		try:
			temp = [registered[ test_day[0:8] + measure[i] + test_day[10:] ] ]
			temp = list(map(int, temp))
			measure_casuals = measure_casuals + temp
		except:
			pass
#measure_casuals = list(map(int, [casual[ test_day[0:8] + measure[i] + test_day[10:] ] for i in range(len(measure))] ))

	slopes = [measure_casuals[i] - measure_casuals[i-1] for i in range(1, len(measure_casuals))]
	if len(slopes) <= 1:
		avg_slope = 1
	else:
		avg_slope = sum(slopes) / len(slopes)

	#result = ((day - measure_numbers[-1])/7 * avg_slope) + measure_casuals[-1]
	result = sum(measure_casuals) / len(measure_casuals)
	result = int(round(result, 0))

	if result > 0 :
		return result
	else:
		return 0


#answer = predict_registered(test_data[614][0])

answer = [predict_registered(i[0]) + predict_casual(i[0]) for i in test_data]

output = open("heuristic.csv", "w")
output.write("datetime,count\n")
for i in range(len(answer)):
	output.write(test_data[i][0] + ","+ str(answer[i]) + "\n")

output.close()