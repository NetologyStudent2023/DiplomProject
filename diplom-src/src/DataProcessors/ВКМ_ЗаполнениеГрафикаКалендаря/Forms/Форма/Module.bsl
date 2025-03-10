
#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	Курсор = Период.ДатаНачала;
	
	Пока Курсор <= Период.ДатаОкончания Цикл
		
		Запись = РегистрыСведений.ВКМ_ГрафикКалендарь.СоздатьМенеджерЗаписи();
		Запись.Дата = Курсор;
		
		Если ДеньНедели(Курсор) <= 5 Тогда
			Запись.РабочийДень = 1;			
		КонецЕсли;
		
		Запись.Записать();
		
		Курсор = Курсор + 86400;
	КонецЦикла;
	
	
КонецПроцедуры

#КонецОбласти
