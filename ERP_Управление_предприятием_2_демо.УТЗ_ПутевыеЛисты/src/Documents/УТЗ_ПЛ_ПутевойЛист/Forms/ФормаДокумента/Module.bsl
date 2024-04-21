
////////////////////////////////////////////////////////////////////////////////
// Параметры формы:
// ЭтоСкопированный - Булево - Используется для проверки на копирование на стороне клиента
//  
////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	Если ЗначениеЗаполнено(Параметры.ЗначениеКопирования) Тогда
		
		ДанныеАТ = УТЗ_ПЛ_АвтотранспортВызовСервера.СведенияОбАвтотранспортеНаДату(Объект.ОсновнойАвтотранспорт,
						 														   ТекущаяДатаСеанса());
		Объект.ВидПутевогоЛиста = ДанныеАТ.ВидПутевогоЛиста;
		Объект.Водитель = ДанныеАТ.ОсновнойВодитель;
		Объект.ПодразделениеВладелец = ДанныеАТ.ПодразделениеВладелец;
		Объект.ПробегПриУбытии = ДанныеАТ.Пробег;
		Объект.ОстатокТопливаПриУбытии = ДанныеАТ.ОстатокТоплива; 	
		
		Параметры.ЭтоСкопированный = Истина;
		
	КонецЕсли;
	
	Основание = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьЗаголовокСтраницыМаршруты();
	ОбновитьВидимостьПрицепаГрузаМаршрут();
	
	Если Параметры.ЭтоСкопированный Тогда
		
		ПересчитатьДанныеСтрокТЧМаршрутПострочно();
		РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
		РассчитатьКонечныйПробегПоПутевомуЛисту();
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.Основание) 
		И ЗначениеЗаполнено(Объект.ОсновнойАвтотранспорт) Тогда
		УстановитьТипРеквизитаОснование();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Оповестить("Запись_УТЗ_ПЛ_ПутевойЛист");
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КомментарийНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	ОбщегоНазначенияКлиент.ПоказатьФормуРедактированияКомментария(Объект.Комментарий, ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ОсновнойАвтотранспортПриИзменении(Элемент)
	//  Структура:
	//		* ВидАвтотранспорта	- ПеречислениеСсылка.УТЗ_ПЛ_ВидыАвтотранспорта
	//		* Модель - СправочникСсылка.УТЗ_ПЛ_МоделиАвтотранспорта
	//		* ВидПутевогоЛиста - ПеречислениеСсылка.УТЗ_ПЛ_ВидыПутевыхЛистов
	//		* ДатаВводаВЭксплуатацию - Дата
	//		* Возраст - Число
	//		* ОсновнойВодитель - СправочникСсылка.УТЗ_ПЛ_Водители
	//		* ПодразделениеВладелец - СправочникСсылка.СтруктураПредприятия
	//		* Топливо - СправочникСсылка.УТЗ_ПЛ_Топливо
	//		* Пробег - Число
	//		* ОстатокТоплива - Число
	//		* НормаРасходаОсновная - Число
	//		* НормаРасходаДополнительнаяНаПеревозку - Число
	//		* Моточасы - Число
	ДанныеАТ = УТЗ_ПЛ_АвтотранспортВызовСервера.СведенияОбАвтотранспортеНаДату(Объект.ОсновнойАвтотранспорт, 
																				ДатаАктуальностиПолученияДанных());
	Объект.ВидПутевогоЛиста = ДанныеАТ.ВидПутевогоЛиста;
	Объект.Водитель = ДанныеАТ.ОсновнойВодитель;
	Объект.ПодразделениеВладелец = ДанныеАТ.ПодразделениеВладелец;
	Объект.ПробегПриУбытии = ДанныеАТ.Пробег;
	Объект.ОстатокТопливаПриУбытии = ДанныеАТ.ОстатокТоплива;
	
	ПересчитатьДанныеСтрокТЧМаршрутПострочно();
	РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
	РассчитатьКонечныйПробегПоПутевомуЛисту();
	
	Если ЗначениеЗаполнено(Объект.ОсновнойАвтотранспорт) Тогда
		УстановитьТипРеквизитаОснование();
	Иначе
		Объект.Основание = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаВремяУбытияПриИзменении(Элемент)
	ПересчитатьДанныеСтрокТЧМаршрутПострочно();
КонецПроцедуры

&НаКлиенте
Процедура ВидПутевогоЛистаПриИзменении(Элемент)
	ОбновитьВидимостьПрицепаГрузаМаршрут();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыМаршрут

&НаКлиенте
Процедура МаршрутПриИзменении(Элемент)
	ОбновитьЗаголовокСтраницыМаршруты();
КонецПроцедуры

&НаКлиенте
Процедура МаршрутПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НоваяСтрока Тогда
		ТекДанн = Элементы.Маршрут.ТекущиеДанные;
		ТекДанн.ДатаВремяУбытия = ДатаВремяУбытияПоСтроке(ТекДанн.НомерСтроки);
		ТекДанн.ПробегПриУбытии = ПробегПриУбытииПоСтроке(ТекДанн.НомерСтроки);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура МаршрутПослеУдаления(Элемент)
	ПересчитатьДанныеСтрокТЧМаршрутПострочно();
КонецПроцедуры

&НаКлиенте
Процедура МаршрутВремяВПутиПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ПересчитатьДанныеСтрокТЧМаршрутПострочно(ТекДанн.НомерСтроки);
КонецПроцедуры

&НаКлиенте
Процедура МаршрутВремяОжиданияНаПунктеПрибытияПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ПересчитатьДанныеСтрокТЧМаршрутПострочно(ТекДанн.НомерСтроки);
КонецПроцедуры

&НаКлиенте
Процедура МаршрутРасстояниеПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ПересчитатьДанныеСтрокТЧМаршрутПострочно(ТекДанн.НомерСтроки);
	ТекДанн.НормаРасходаТоплива = НормативныйРасходТопливаПоСтроке(ТекДанн.НомерСтроки);
	Объект.РасходТопливаПлан = Объект.Маршрут.Итог("НормаРасходаТоплива");
КонецПроцедуры

&НаКлиенте
Процедура МаршрутКоэффициентРазмерНаселенногоПунктаПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ТекДанн.НормаРасходаТоплива = НормативныйРасходТопливаПоСтроке(ТекДанн.НомерСтроки);
	Объект.РасходТопливаПлан = Объект.Маршрут.Итог("НормаРасходаТоплива");
КонецПроцедуры

&НаКлиенте
Процедура МаршрутКоэффициентКлассаДорогиПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ТекДанн.НормаРасходаТоплива = НормативныйРасходТопливаПоСтроке(ТекДанн.НомерСтроки);
	Объект.РасходТопливаПлан = Объект.Маршрут.Итог("НормаРасходаТоплива");
КонецПроцедуры

&НаКлиенте
Процедура МаршрутСуммарнаяМассаГрузаПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ТекДанн.НормаРасходаТоплива = НормативныйРасходТопливаПоСтроке(ТекДанн.НомерСтроки);
	Объект.РасходТопливаПлан = Объект.Маршрут.Итог("НормаРасходаТоплива");
КонецПроцедуры

&НаКлиенте
Процедура МаршрутПрицепПриИзменении(Элемент)
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	ТекДанн.НормаРасходаТоплива = НормативныйРасходТопливаПоСтроке(ТекДанн.НомерСтроки);
	Объект.РасходТопливаПлан = Объект.Маршрут.Итог("НормаРасходаТоплива");
КонецПроцедуры

&НаКлиенте
Процедура МаршрутФактическийРасходТопливаПриИзменении(Элемент)
	РассчитатьФактическийРасходОсновногоТранспорта();
	РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
КонецПроцедуры

&НаКлиенте
Процедура МаршрутПунктУбытияПриИзменении(Элемент)
	ЗаполнитьВремяРасстояниеМеждуПунктами();
	ПересчитатьДанныеСтрокТЧМаршрутПострочно(НомерТекущейСтрокиМаршрут());
КонецПроцедуры

&НаКлиенте
Процедура МаршрутПунктПрибытияПриИзменении(Элемент)
	ЗаполнитьВремяРасстояниеМеждуПунктами();
	ПересчитатьДанныеСтрокТЧМаршрутПострочно(НомерТекущейСтрокиМаршрут());
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПриходТоплива

&НаКлиенте
Процедура ПриходТопливаПриИзменении(Элемент)
	РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДополнительныйРасходТоплива

&НаКлиенте
Процедура ДополнительныйРасходТопливаПриИзменении(Элемент)
	РассчитатьФактическийРасходОсновногоТранспорта();
	РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
КонецПроцедуры

&НаКлиенте
Процедура РасходТопливаРасходФактПриИзменении(Элемент)
	РассчитатьФактическийРасходОсновногоТранспорта();
	РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаполнитьТопливнуюКартуДополнительныйРасход(Команда)
	Карта = ТопливнаяКартаВодителя(Объект.Водитель);
	
	Для Каждого Строка Из Объект.ДополнительныйРасходТоплива Цикл
		Строка.ТопливнаяКарта = Карта;	
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТопливнуюКартуМаршрут(Команда)
	
	Карта = ТопливнаяКартаВодителя(Объект.Водитель);
	
	Для Каждого Строка Из Объект.Маршрут Цикл
		Строка.ТопливнаяКарта = Карта;	
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТопливнуюКартуПриходТоплива(Команда)
	Карта = ТопливнаяКартаВодителя(Объект.Водитель);
	
	Для Каждого Строка Из Объект.ПриходТоплива Цикл
		Строка.ТопливнаяКарта = Карта;	
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Асинх Процедура РаспределитьФактическийРасход(Команда)
	
	Число = 0;
	ОбщийФактическийРасход = Ждать ВвестиЧислоАсинх(Число, "Введите общий фактический расход по маршруту", 10, 3);
	
	Если ТипЗнч(ОбщийФактическийРасход) = Тип("Число") Тогда 
		Если ОбщийФактическийРасход > 0 Тогда
			РаспределитьФактическийРасходПропорциональноНормативному(ОбщийФактическийРасход);
			РассчитатьФактическийРасходОсновногоТранспорта();
			РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
		Иначе
			ОбщегоНазначенияКлиент.СообщитьПользователю("Введенное число должно быть больше 0");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеТЧМаршрут(Команда)
	ПересчитатьДанныеСтрокТЧМаршрутПострочно();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ПодключаемыеКоманды
 
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Объект);	
КонецПроцедуры
 
&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(ПараметрыВызова, Результат)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВызова, Объект, Результат);
КонецПроцедуры
 
&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
 
#КонецОбласти

#Область ПроцедурыФункцииМаршрут

&НаКлиенте
Функция ДатаВремяУбытияПоСтроке(НомерСтроки = 1)

	ДатаВремяУбытия = Дата(1, 1, 1);
	
	Если НомерСтроки = 1 Тогда
		ДатаВремяУбытия = Объект.ДатаВремяУбытия;
	Иначе
		ПредыдущаяСтрока = Объект.Маршрут.Получить(НомерСтроки - 2);
		
		Если ЗначениеЗаполнено(ПредыдущаяСтрока.ВремяОжиданияНаПунктеПрибытия) Тогда 
			// прибавляем время ожидания к дате времени пред. пункта
			ДатаВремяУбытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(ПредыдущаяСтрока.ДатаВремяПрибытия,
																ПредыдущаяСтрока.ВремяОжиданияНаПунктеПрибытия,
																"Час, Минута");
			
		Иначе // возвращаем дату и время прибытия в предыдущий пункт
			
			ДатаВремяУбытия = ПредыдущаяСтрока.ДатаВремяПрибытия;
			
		КонецЕсли;
	КонецЕсли;
	
	Возврат ДатаВремяУбытия;
	
КонецФункции

&НаКлиенте
Функция ПробегПриУбытииПоСтроке(НомерСтроки = 1)
	
	ПробегПриУбытии = 0;	
	
	Если НомерСтроки = 1 Тогда
		ПробегПриУбытии = Объект.ПробегПриУбытии;
	Иначе
		ПредыдущаяСтрока = Объект.Маршрут.Получить(НомерСтроки - 2);
		ПробегПриУбытии = ПредыдущаяСтрока.ПробегПриПрибытии;
	КонецЕсли;
	
	Возврат ПробегПриУбытии;
	
КонецФункции

// Пересчитывает данные дат, пробегов и расхода по путевому листу с 
// указанной строки вниз
&НаКлиенте
Процедура ПересчитатьДанныеСтрокТЧМаршрутПострочно(НачальныйНомерСтроки = 1)
	
	Если НачальныйНомерСтроки < 1 Тогда
		Возврат;
	КонецЕсли;
	
	Если НачальныйНомерСтроки = 1 Тогда
		РасчетнаяДата = Объект.ДатаВремяУбытия;
		РасчетныйПробег = Объект.ПробегПриУбытии;
	Иначе
		ПредыдущаяСтрока = Объект.Маршрут.Получить(НачальныйНомерСтроки - 2);
		РасчетнаяДата = ПредыдущаяСтрока.ДатаВремяПрибытия;
		РасчетныйПробег = ПредыдущаяСтрока.ПробегПриПрибытии;
	КонецЕсли;
	
	КоличествоСтрок = Объект.Маршрут.Количество();
	
	Для Сч = НачальныйНомерСтроки По КоличествоСтрок Цикл
		
		Строка = Объект.Маршрут.Получить(Сч - 1);
		
		Строка.ДатаВремяУбытия = РасчетнаяДата;
		Строка.ПробегПриУбытии = РасчетныйПробег;
		
		// Рассчитываем дату прибытия
		Строка.ДатаВремяПрибытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(Строка.ДатаВремяУбытия, 
																				Строка.ВремяВПути,
																				"Час, Минута");
		
		// Рассчитываем пробег
		Строка.ПробегПриПрибытии = Строка.ПробегПриУбытии + Строка.Расстояние;
		
		// обновляем переменные для следующей итерации цикла
		РасчетныйПробег = Строка.ПробегПриПрибытии;
		
		Если ЗначениеЗаполнено(Строка.ВремяОжиданияНаПунктеПрибытия) Тогда // дата следующего отправление сдвигается
			РасчетнаяДата = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(Строка.ДатаВремяПрибытия,
																		 Строка.ВремяОжиданияНаПунктеПрибытия,
																		 "Час, Минута");
		Иначе
			РасчетнаяДата = Строка.ДатаВремяПрибытия;
		КонецЕсли;
		
		Строка.НормаРасходаТоплива = НормативныйРасходТопливаПоСтроке(Строка.НомерСтроки);
		
	КонецЦикла;
	
	// заполняем итоговые значения в шапке документа
	Объект.ДатаВремяПрибытия = РасчетнаяДата;
	Объект.ПробегПриПрибытии = РасчетныйПробег;
	
	Объект.РасходТопливаПлан = Объект.Маршрут.Итог("НормаРасходаТоплива");
	Объект.РасходТопливаФакт = Объект.Маршрут.Итог("ФактическийРасходТоплива");
	
	РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту();
	
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьКонечныйПробегПоПутевомуЛисту()
	Объект.ПробегПриПрибытии = Объект.ПробегПриУбытии + Объект.Маршрут.Итог("Расстояние");	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗаголовокСтраницыМаршруты() 

	КоличествоПунктов = Объект.Маршрут.Количество();
	ЗаголовокПункта = "пункт";
	
	Если КоличествоПунктов = 1 Тогда
		ЗаголовокПункта = "пункт";
	ИначеЕсли КоличествоПунктов >= 2 И КоличествоПунктов <= 4 Тогда
		ЗаголовокПункта = "пункта";
	Иначе
		ЗаголовокПункта = "пунктов";
	КонецЕсли;
	
	Элементы.ГруппаМаршрут.Заголовок = СтрШаблон("Маршрут - %1 %2 (%3 км)",
												 КоличествоПунктов,
												 ЗаголовокПункта,
												 Объект.Маршрут.Итог("Расстояние"));
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьВидимостьПрицепаГрузаМаршрут()

	Если Объект.ВидПутевогоЛиста = ВидПутевогоЛистаЛегковой() Тогда
		Элементы.МаршрутГруппаПрицепГруз.Видимость = Ложь;
	Иначе
		Элементы.МаршрутГруппаПрицепГруз.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьВремяРасстояниеМеждуПунктами()

	ТекДанн = Элементы.Маршрут.ТекущиеДанные;	
	
	ПараметрыЗаполнения = Новый Структура;
	ПараметрыЗаполнения.Вставить("ВремяВПути", Дата(1, 1, 1));
	ПараметрыЗаполнения.Вставить("Расстояние", 0);
	
	Если ЗначениеЗаполнено(Объект.ОсновнойАвтотранспорт)
		И ЗначениеЗаполнено(ТекДанн.ПунктПрибытия) 
		И ЗначениеЗаполнено(ТекДанн.ПунктУбытия) Тогда
		
		ВремяРасстояние 
			= УТЗ_ПЛ_ПунктыМаршрутаКлиент.ВремяРасстояниеМеждуПунктамиМаршрута(Объект.ОсновнойАвтотранспорт,
																				ТекДанн.ПунктУбытия,
																				ТекДанн.ПунктПрибытия);
		ЗаполнитьЗначенияСвойств(ПараметрыЗаполнения, ВремяРасстояние);
		
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ТекДанн, ПараметрыЗаполнения);
	
КонецПроцедуры

#КонецОбласти

#Область ПроцедурыФункцииРасчетТоплива

&НаКлиенте
Функция НормативныйРасходТопливаПоСтроке(НомерСтроки)

	ТекДанн = Объект.Маршрут.Получить(НомерСтроки - 1);
	
	//	* Автотранспорт - СправочникСсылка.УТЗ_ПЛ_Автотранспорт
	//	* Прицеп - СправочникСсылка.УТЗ_ПЛ_Автотранспорт
	//	* СуммарнаяМассаГруза - Число
	//	* Расстояние - Число
	//	* КоэффициентНаселенногоПункта - СправочникСсылка.УТЗ_ПЛ_КоэффициентыРасходаТоплива
	//	* КоэффициентКлассаДороги - СправочникСсылка.УТЗ_ПЛ_КоэффициентыРасходаТоплива
	//	* (не используется) КоэффициентГорнойМестности - СправочникСсылка.УТЗ_ПЛ_КоэффициентыРасходаТоплива
	ПараметрыПолучения = УТЗ_ПЛ_АвтотранспортВызовСервера.ПараметрыПолученияНормативногоРасходаТоплива();
	ПараметрыПолучения.Автотранспорт = Объект.ОсновнойАвтотранспорт;
	ПараметрыПолучения.СуммарнаяМассаГруза = ТекДанн.СуммарнаяМассаГруза;
	ПараметрыПолучения.Расстояние = ТекДанн.Расстояние;
	ПараметрыПолучения.КоэффициентНаселенногоПункта = ТекДанн.КоэффициентРазмерНаселенногоПункта;
	ПараметрыПолучения.КоэффициентКлассаДороги = ТекДанн.КоэффициентКлассаДороги;
	
	НормативныйРасход = УТЗ_ПЛ_АвтотранспортВызовСервера.НормативныйРасходТопливаАвтотранспорта(ПараметрыПолучения, 
																				ДатаАктуальностиПолученияДанных()); 
	
	Возврат НормативныйРасход;
	
КонецФункции

&НаКлиенте
Процедура РассчитатьКонечныйОстатокТопливаПоПутевомуЛисту()
	
	Объект.ОстатокТопливаПриПрибытии = Объект.ОстатокТопливаПриУбытии 
											+ ПриходТопливаАвтотранспорта() 
											- Объект.Маршрут.Итог("ФактическийРасходТоплива")
											- РасходТопливаАвтотранспортаДополнительный();
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьФактическийРасходОсновногоТранспорта()

	Объект.РасходТопливаФакт = Объект.Маршрут.Итог("ФактическийРасходТоплива")
								+ РасходТопливаАвтотранспортаДополнительный();
	
КонецПроцедуры

&НаКлиенте
Функция ПриходТопливаАвтотранспорта()
	
	Строки = Объект.ПриходТоплива.НайтиСтроки(Новый Структура("Автотранспорт", Объект.ОсновнойАвтотранспорт));
	
	ПриходТоплива = 0;
	
	Для Каждого Строка Из Строки Цикл
		ПриходТоплива = ПриходТоплива + Строка.Количество;
	КонецЦикла;
	
	Возврат ПриходТоплива;
	
КонецФункции

&НаКлиенте
Функция РасходТопливаАвтотранспортаДополнительный()
	
	ПараметрыОтбора = Новый Структура("Автотранспорт", Объект.ОсновнойАвтотранспорт);
	Строки = Объект.ДополнительныйРасходТоплива.НайтиСтроки(ПараметрыОтбора);
	
	РасходТоплива = 0;
	
	Для Каждого Строка Из Строки Цикл
		РасходТоплива = РасходТоплива + Строка.РасходФакт;
	КонецЦикла;
	
	Возврат РасходТоплива;
	
КонецФункции

&НаСервереБезКонтекста
Функция ТопливнаяКартаВодителя(Знач Водитель)

	ТопливнаяКарта = Справочники.УТЗ_ПЛ_ТопливныеКарты.ПустаяСсылка();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ТопливныеКарты.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.УТЗ_ПЛ_ТопливныеКарты КАК УТЗ_ПЛ_ТопливныеКарты
	|ГДЕ
	|	УТЗ_ПЛ_ТопливныеКарты.ВладелецКарты = &ВладелецКарты";
	Запрос.УстановитьПараметр("ВладелецКарты", Водитель);
	
	Результат = Запрос.Выполнить();
	
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ТопливнаяКарта = Выборка.Ссылка;
	КонецЕсли;
	
	Возврат ТопливнаяКарта;
	
КонецФункции

&НаКлиенте
Процедура РаспределитьФактическийРасходПропорциональноНормативному(ФактическийРасход)
	
	// Определяем пропорции по нормативному расходу
	
	СуммарныйНормативныйРасход = Объект.Маршрут.Итог("НормаРасходаТоплива");
	
	// Очищаем фактический расход
	Для Каждого СтрокаТЧ Из Объект.Маршрут Цикл
		СтрокаТЧ.ФактическийРасходТоплива = 0;
	КонецЦикла;
	
	// Распределяем пропорционально
	Для Сч = 1 По Объект.Маршрут.Количество() Цикл
		
		Строка = Объект.Маршрут.Получить(Сч - 1);
		
		Если Сч = Объект.Маршрут.Количество() Тогда
			Строка.ФактическийРасходТоплива = ФактическийРасход - Объект.Маршрут.Итог("ФактическийРасходТоплива");
		КонецЕсли;
		
		Коэффициент = Окр(Строка.НормаРасходаТоплива / СуммарныйНормативныйРасход, 3);
		Строка.ФактическийРасходТоплива = Окр(ФактическийРасход * Коэффициент, 3);
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ПрочиеПроцедурыИФункции

&НаКлиенте
Функция ДатаАктуальностиПолученияДанных()
	
	ДатаАктуальности = Дата(1, 1, 1);
	
	Если ЗначениеЗаполнено(Объект.Дата) Тогда
		ДатаАктуальности = Объект.Дата;
	Иначе
		ДатаАктуальности = ТекущаяДата();
	КонецЕсли;
	
	Возврат ДатаАктуальности;
	
КонецФункции

&НаСервереБезКонтекста
Функция ВидПутевогоЛистаЛегковой()
	Возврат Перечисления.УТЗ_ПЛ_ВидыПутевыхЛистов.Легковой;	
КонецФункции

&НаКлиенте
Процедура УстановитьТипРеквизитаОснование()
	
	Если Не ЗначениеЗаполнено(Объект.ОсновнойАвтотранспорт) Тогда
		Объект.Основание = Неопределено;
		Возврат;
	КонецЕсли;
	
	Если ЭтоЛегковойАвтотранспорт(Объект.ОсновнойАвтотранспорт) Тогда
		Объект.Основание = ЗаявкаНаЛегковойАвтотранспортПустаяСсылка();
	ИначеЕсли ЭтоГрузовойАвтотранспорт(Объект.ОсновнойАвтотранспорт) Тогда
		Объект.Основание = ЗаявкаНаГрузовойАвтотранспортПустаяСсылка();
	Иначе 
		Объект.Основание = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ТипАвтотранспорта(ОсновнойАвтотранспорт)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_Автотранспорт.ТипАвтотранспорта КАК ТипАвтотранспорта
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт КАК УТЗ_ПЛ_Автотранспорт
	|ГДЕ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ОсновнойАвтотранспорт);
		
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.ТипАвтотранспорта;
	
КонецФункции

&НаСервереБезКонтекста
Функция ЭтоЛегковойАвтотранспорт(Знач ОсновнойАвтотранспорт)
	
	ТипАвто = ТипАвтотранспорта(ОсновнойАвтотранспорт);
	
	Ответ = Ложь;
	Если ТипАвто = Перечисления.УТЗ_ПЛ_ТипыАвтотранспорта.Легковой Тогда
		Ответ = Истина;
	КонецЕсли;
	
	Возврат Ответ;
	
КонецФункции

&НаСервереБезКонтекста
Функция ЭтоГрузовойАвтотранспорт(Знач ОсновнойАвтотранспорт)
	
	ТипАвто = ТипАвтотранспорта(ОсновнойАвтотранспорт);
	
	Ответ = Ложь;
	Если ТипАвто = Перечисления.УТЗ_ПЛ_ТипыАвтотранспорта.Грузовой Тогда
		Ответ = Истина;
	КонецЕсли;
	
	Возврат Ответ;
	
КонецФункции

&НаСервереБезКонтекста
Функция ЗаявкаНаЛегковойАвтотранспортПустаяСсылка()
	Возврат Документы.УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.ПустаяСсылка();	
КонецФункции

&НаСервереБезКонтекста
Функция ЗаявкаНаГрузовойАвтотранспортПустаяСсылка()
	Возврат Документы.УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.ПустаяСсылка();	
КонецФункции

&НаКлиенте
Функция НомерТекущейСтрокиМаршрут()
	
	НомерСтроки = -1;
	
	ТекДанн = Элементы.Маршрут.ТекущиеДанные;
	
	Если ТекДанн <> Неопределено Тогда
		НомерСтроки = ТекДанн.НомерСтроки;
	КонецЕсли;
	
	Возврат НомерСтроки;
	
КонецФункции

#КонецОбласти

#КонецОбласти