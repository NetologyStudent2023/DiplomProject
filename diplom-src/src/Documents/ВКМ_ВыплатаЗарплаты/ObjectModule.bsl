Процедура ОбработкаПроведения(Отказ,Режим)
		
	// регистр ВКМ_ВзаиморасчетыССотрудниками
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	Для Каждого ТекСтрокаВыплаты из Выплаты Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.Период = Дата;
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Сотрудник = ТекСтрокаВыплаты.Сотрудник;
		Движение.Сумма = ТекСтрокаВыплаты.Сумма;
	КонецЦикла;
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();

КонецПроцедуры