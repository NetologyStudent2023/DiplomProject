﻿#language: ru

@tree

Функционал: Демонстрация вызова экспортного сценария - закрытие документа ОбслуживаниеКлиента

	Как Тестировщик я хочу
	создать сценарий по закрытию обслуживания клиента от имени Специалист (Иванов И.И., Петров А.Н.)
	чтобы автоматизировать работу по заполнению документов и отчетности

Контекст:
	Дано я закрываю TestClient "ДипломныйПроект"
	
Структура сценария: закрытие документа ОбслуживаниеКлиента

	И я подключаю TestClient "ДипломныйПроект" логин "ПетровАН" пароль ""
	* И я открываю форму списка документов ОбслуживаниеКлиента
			Когда В панели разделов я выбираю 'Добавленные объекты'
			И Я нажимаю кнопку командного интерфейса 'Обслуживание клиентов'
			Тогда открылось окно 'Обслуживание клиентов'
	
		И в таблице "Список" я перехожу к последней строке
		И я закрываю документ ОбслуживаниеКлиента с параметрами <ГК_ОписаниеРабот>, <ГК_ЧасовРаботы>, <ГК_ЧасовКОплате> 
	Примеры:
| 'ГК_ОписаниеРабот' | 'ГК_ЧасовРаботы' | 'ГК_ЧасовКОплате' |
| "Много работы"     | "5"              | "5"               |
