
#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Ответственный = Пользователи.ТекущийПользователь();
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.УТЗ_ПЛ_ПробегАвтотранспорта.Записывать = Истина;
	
	Для Каждого ТекСтрокаСписокАвтотранспорта Из СписокАвтотранспорта Цикл
		Движение = Движения.УТЗ_ПЛ_ПробегАвтотранспорта.Добавить();
		Если ТекСтрокаСписокАвтотранспорта.ВидДвижения = Перечисления.УТЗ_ПЛ_ВидыДвиженийКорректировок.Приход Тогда
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;	
		ИначеЕсли ТекСтрокаСписокАвтотранспорта.ВидДвижения = Перечисления.УТЗ_ПЛ_ВидыДвиженийКорректировок.Расход Тогда
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		КонецЕсли;
		
		Движение.Период = Дата;
		Движение.Автотранспорт = ТекСтрокаСписокАвтотранспорта.Автотранспорт;
		Движение.Количество = ТекСтрокаСписокАвтотранспорта.Количество;
		Движение.Ответственный = Ответственный;
	КонецЦикла;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	МассивАвтотранспорта = СписокАвтотранспорта.ВыгрузитьКолонку("Автотранспорт");
	МассивБезДубликатов = ОбщегоНазначенияКлиентСервер.СвернутьМассив(МассивАвтотранспорта);
	СписокАвтотранспортаСтрокой = СтрСоединить(МассивБезДубликатов, ", ");
	
КонецПроцедуры



#КонецОбласти
