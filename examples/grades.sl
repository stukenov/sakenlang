let student = "Арман"
var grade = 85

if grade > 89 {
    print(student + " - Отлично!")
} else {
    if grade > 74 {
        print(student + " - Хорошо")
    } else {
        if grade > 59 {
            print(student + " - Удовлетворительно")
        } else {
            print(student + " - Неудовлетворительно")
        }
    }
}

print("Балл: ")
print(grade)
