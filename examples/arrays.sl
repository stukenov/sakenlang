// Массивы
var scores = [85, 92, 78, 95, 88]
var i = 0
var total = 0

while i < len(scores) {
    total = total + scores[i]
    i = i + 1
}

print("Сумма баллов:")
print(total)
