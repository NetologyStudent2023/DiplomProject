#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ,Режим)
	
	СформироватьДвижения();
	РассчитатьОклад();
	РассчитатьОтпуск();
	РассчитатьУдержания();
	РассчитатьВыплаты();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура СформироватьДвижения()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_НачислениеЗарплатыНачисления.Ссылка КАК Ссылка,
	|	ВКМ_НачислениеЗарплатыНачисления.Сотрудник КАК Сотрудник,
	|	ВКМ_НачислениеЗарплатыНачисления.ВидРасчета КАК ВидРасчета,
	|	ВКМ_НачислениеЗарплатыНачисления.НачалоПериода КАК НачалоПериода,
	|	ВКМ_НачислениеЗарплатыНачисления.КонецПериода КАК КонецПериода,
	|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Оклад КАК Оклад,
	|	ЕСТЬNULL(ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот, ЛОЖЬ) КАК ПроцентОтРабот,
	|	ЕСТЬNULL(ВКМ_ВыполненныеСотрудникомРаботыОстатки.СуммаКОплатеОстаток, 0) КАК СуммаКОплатеОтРабот
	|ИЗ
	|	Документ.ВКМ_НачислениеЗарплаты.Начисления КАК ВКМ_НачислениеЗарплатыНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(&Период,) КАК
	|			ВКМ_УсловияОплатыСотрудниковСрезПоследних
	|		ПО ВКМ_НачислениеЗарплатыНачисления.Сотрудник = ВКМ_УсловияОплатыСотрудниковСрезПоследних.Сотрудник
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ВКМ_ВыполненныеСотрудникомРаботы.Остатки(&Период,) КАК
	|			ВКМ_ВыполненныеСотрудникомРаботыОстатки
	|		ПО ВКМ_НачислениеЗарплатыНачисления.Сотрудник = ВКМ_ВыполненныеСотрудникомРаботыОстатки.Сотрудник
	|ГДЕ
	|	ВКМ_НачислениеЗарплатыНачисления.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Период", Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		// регистр ВКМ_ОсновныеНачисления
		Движение = Движения.ВКМ_ОсновныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = Выборка.ВидРасчета;
		Движение.ПериодРегистрации = Дата;
		Движение.ПериодДействияНачало = Выборка.НачалоПериода;
		Движение.ПериодДействияКонец = Выборка.КонецПериода;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.СуммаОклада = Выборка.Оклад;
		Движение.СуммаКОплатеОтРабот = Выборка.СуммаКОплатеОтРабот;
				
		Если Выборка.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск Тогда
			Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(Дата, -12));
			Движение.БазовыйПериодКонец = КонецМесяца(ДобавитьМесяц(Дата, -1));
			
			// регистр ВКМ_ПланированиеОтпусков
	 		НовоеДвижение = Движения.ВКМ_ПланированиеОтпусков.Добавить();
			НовоеДвижение.Период = Дата;
			НовоеДвижение.ВидДвижения = ВидДвиженияНакопления.Расход;
			НовоеДвижение.Сотрудник = Выборка.Сотрудник;
			НовоеДвижение.Год = ГОД(Дата);
			НовоеДвижение.КоличествоДней = ЦЕЛ((Выборка.КонецПериода - Выборка.НачалоПериода) / 86400);
		КонецЕсли;
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать();
	Движения.ВКМ_ПланированиеОтпусков.Записать();
КонецПроцедуры

Процедура РассчитатьОклад()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки,
	|	ВКМ_ОсновныеНачисленияДанныеГрафика.РабочийДеньФактическийПериодДействия КАК РабочихДнейОтработано,
	|	ВКМ_ОсновныеНачисленияДанныеГрафика.РабочийДеньПериодДействия КАК РабочихДнейНорма
	|ИЗ
	|	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(Регистратор = &Ссылка
	|	И ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Оклад)) КАК ВКМ_ОсновныеНачисленияДанныеГрафика";
		
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.ДнейОтработано = Выборка.РабочихДнейОтработано;
		Коэф = 1;
		
		Если Выборка.РабочихДнейОтработано <> Выборка.РабочихДнейНорма Тогда
			 Коэф = Выборка.РабочихДнейОтработано / Выборка.РабочихДнейНорма;
		КонецЕсли;
		
		Движение.Результат = Движение.СуммаОклада * Коэф + Движение.СуммаКОплатеОтРабот;		
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
		
КонецПроцедуры

Процедура РассчитатьОтпуск()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
	|	ЕСТЬNULL(СУММА(ВКМ_ДополнительныеНачисления.Результат), 0) КАК ПремияБаза
	|ПОМЕСТИТЬ В_ТаблицаПремийБаза
	|ИЗ
	|	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
	|		ПО ВКМ_ОсновныеНачисления.Сотрудник = ВКМ_ДополнительныеНачисления.Сотрудник
	|ГДЕ
	|	ВКМ_ОсновныеНачисления.Регистратор = &Регистратор
	|	И ВКМ_ОсновныеНачисления.ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск)
	|	И ВКМ_ДополнительныеНачисления.ПериодРегистрации
	|		МЕЖДУ ВКМ_ОсновныеНачисления.БазовыйПериодНачало И ВКМ_ОсновныеНачисления.БазовыйПериодКонец
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_ОсновныеНачисления.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВКМ_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
	|	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.РезультатБаза КАК ОкладБаза,
	|	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ДнейОтработаноБаза КАК ДнейОтработаноБаза,
	|	ВКМ_ОсновныеНачисленияДанныеГрафика.РабочийДеньФактическийПериодДействия КАК Факт,
	|	ЕСТЬNULL(В_ТаблицаПремийБаза.ПремияБаза, 0) КАК ПремияБаза
	|ИЗ
	|	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.БазаВКМ_ОсновныеНачисления(&Измерения, &Измерения,,
	|			Регистратор = &Регистратор
	|		И ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск)) КАК
	|			ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления
	|		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.НомерСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(Регистратор = &Регистратор
	|		И ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск)) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
	|		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ В_ТаблицаПремийБаза КАК В_ТаблицаПремийБаза
	|		ПО ВКМ_ОсновныеНачисления.Сотрудник = В_ТаблицаПремийБаза.Сотрудник
	|ГДЕ
	|	ВКМ_ОсновныеНачисления.ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск)
	|	И ВКМ_ОсновныеНачисления.Регистратор = &Регистратор";
		
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	
	Запрос.УстановитьПараметр("Измерения", Измерения);
	
	Выборка = Запрос.Выполнить().Выбрать();
		
	Пока Выборка.Следующий() Цикл
		
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.ДнейОтработано = Выборка.Факт;                                    
		
		Если Выборка.ДнейОтработаноБаза = 0 Тогда
			Движение.Результат = 0;
			Продолжить;			
		КонецЕсли;
		
		Движение.Результат = (Выборка.ОкладБаза + Выборка.ПремияБаза)  * Выборка.Факт / Выборка.ДнейОтработаноБаза; 
	
	КонецЦикла;
		
	Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
		
КонецПроцедуры

Процедура РассчитатьУдержания()
			
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
	|	МИНИМУМ(ЕСТЬNULL(ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.РезультатБаза, 0)) КАК РезультатБаза
	|ИЗ
	|	РегистрРасчета.ВКМ_Удержания.БазаВКМ_ОсновныеНачисления(&Измерения, &Измерения,, Регистратор = &Регистратор
	|	И ВидРасчета = &Удержания) КАК ВКМ_УдержанияБазаВКМ_ОсновныеНачисления
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.Сотрудник";

	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	Запрос.УстановитьПараметр("Удержания", ПланыВидовРасчета.ВКМ_Удержания.НДФЛ);
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	
	Запрос.УстановитьПараметр("Измерения", Измерения);
		
	Выборка = Запрос.Выполнить().Выбрать();
	
	Движения.ВКМ_Удержания.Записывать = Истина;
		
	Пока Выборка.Следующий() Цикл
		// регистр ВКМ_Удержания
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.ПериодРегистрации = Дата;
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.Результат = Выборка.РезультатБаза * 0.13;	
	КонецЦикла;
КонецПроцедуры

Процедура РассчитатьВыплаты()
	
	Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
		|	СУММА(ВКМ_ОсновныеНачисления.Результат) КАК Результат
		|ПОМЕСТИТЬ ВТ_ОсновныеНачисления
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
		|ГДЕ
		|	ВКМ_ОсновныеНачисления.Регистратор = &Регистратор
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ОсновныеНачисления.Сотрудник
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ОсновныеНачисления.Сотрудник,
		|	ВТ_ОсновныеНачисления.Результат КАК ОснНачисления,
		|	ЕСТЬNULL(СУММА(ВКМ_Удержания.Результат), 0) КАК Удержания
		|ИЗ
		|	ВТ_ОсновныеНачисления КАК ВТ_ОсновныеНачисления
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|		ПО ВТ_ОсновныеНачисления.Сотрудник = ВКМ_Удержания.Сотрудник
		|ГДЕ
		|	ВКМ_Удержания.Регистратор = &Регистратор
		|СГРУППИРОВАТЬ ПО
		|	ВТ_ОсновныеНачисления.Сотрудник,
		|	ВТ_ОсновныеНачисления.Результат";
		
		Запрос.УстановитьПараметр("Регистратор", Ссылка);
			
		Выборка = Запрос.Выполнить().Выбрать();
		Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	
		Пока Выборка.Следующий() Цикл
			// регистр ВКМ_ВзаиморасчетыССотрудниками
			Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
			Движение.Период = Дата;
			Движение.Регистратор = Ссылка;
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Сотрудник = Выборка.Сотрудник;
			Движение.Сумма = Выборка.ОснНачисления - Выборка.Удержания;
		КонецЦикла;
		
		Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();
				
КонецПроцедуры

#КонецОбласти
#КонецЕсли
