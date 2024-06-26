
#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УТЗ_ПЛ_Водители.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.УТЗ_ПЛ_Водители КАК УТЗ_ПЛ_Водители
		|ГДЕ
		|	УТЗ_ПЛ_Водители.Ссылка <> &Ссылка
		|	И УТЗ_ПЛ_Водители.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", Наименование);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда 
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Водитель с таким наименованием уже существует в базе данных");
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
