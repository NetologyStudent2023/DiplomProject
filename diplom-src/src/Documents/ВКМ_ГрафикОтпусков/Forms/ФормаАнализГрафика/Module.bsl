#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТабЧасть = ПолучитьИзВременногоХранилища(Параметры.Адрес);
	Объект.Год = ПолучитьИзВременногоХранилища(Параметры.Адрес2);
	
	Для Каждого Строка Из ТабЧасть Цикл
		
		Точка = Диаграмма.УстановитьТочку(Строка.Сотрудник);
		Серия = Диаграмма.УстановитьСерию("Отпуск");
		
		Значение = Диаграмма.ПолучитьЗначение(Точка, Серия);
		Интервал = Значение.Добавить();
		Интервал.Начало = Строка.ДатаНачала;
		Интервал.Конец = Строка.ДатаОкончания;
		
	КонецЦикла;
	
	

КонецПроцедуры

#КонецОбласти
