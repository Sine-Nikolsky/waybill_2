

#Область ПрограммныйИнтерфейс

// Функция - Сумма дат
//
// Параметры:
//  ИсходнаяДата	 - Дата	- 1 слагаемое
//  ДобавляемаяДата	 - Дата - 2 слагаемое
//  ДобавляемыеЧасти - Строка - Части даты, которые необходимо прибавить к исходной дате из добавляемой даты, разделенные запятыми
//								Если не заполнено, тогда даты суммируются полностью
//								Допускается использовать следующие параметры:
//												* "Год"
//												* "Месяц"
//												* "День"
//												* "Час"
//												* "Минута"
//												* "Секунда"
// 
// Возвращаемое значение:
//  Дата - Сумма дат с учетом переданных параметров
//
Функция СуммаДат(Знач ИсходнаяДата, ДобавляемаяДата, ДобавляемыеЧасти = Неопределено) Экспорт
	
	Если ДобавляемыеЧасти = Неопределено Тогда
		
		ДобавляемыеЧасти = Новый Массив;
		ДобавляемыеЧасти.Добавить("Год");
		ДобавляемыеЧасти.Добавить("Месяц");
		ДобавляемыеЧасти.Добавить("День");
		ДобавляемыеЧасти.Добавить("Час");
		ДобавляемыеЧасти.Добавить("Минута");
		ДобавляемыеЧасти.Добавить("Секунда");
		
	КонецЕсли;
	
	Если ТипЗнч(ДобавляемыеЧасти) = Тип("Строка") Тогда
		МассивПараметров = СтрРазделить(ДобавляемыеЧасти, ",", Ложь);
		
		ДобавляемыеЧасти = Новый Массив;
		
		Для Каждого Элемент из МассивПараметров Цикл
			ДобавляемыеЧасти.Добавить(СокрЛП(Элемент));
		КонецЦикла;
		
	КонецЕсли;
	
	СтруктураДаты = СтруктураДаты(ДобавляемаяДата);
	
	Если ДобавляемыеЧасти.Найти("Год") <> Неопределено
		И СтруктураДаты.Свойство("Год") Тогда
		ИсходнаяДата = ДобавитьМесяц(ИсходнаяДата, СтруктураДаты.Год * 12);
	КонецЕсли;
	
	Если ДобавляемыеЧасти.Найти("Месяц") <> Неопределено
		И СтруктураДаты.Свойство("Месяц") Тогда
		ИсходнаяДата = ДобавитьМесяц(ИсходнаяДата, СтруктураДаты.Месяц);
	КонецЕсли;
	
	
	Если ДобавляемыеЧасти.Найти("День") <> Неопределено
		И СтруктураДаты.Свойство("День") Тогда
		ИсходнаяДата = ИсходнаяДата + (СтруктураДаты.День * 24 * 60 * 60);
	КонецЕсли;
	
	
	Если ДобавляемыеЧасти.Найти("Час") <> Неопределено
		И СтруктураДаты.Свойство("Час") Тогда
		ИсходнаяДата = ИсходнаяДата + (СтруктураДаты.Час * 60 * 60);
	КонецЕсли;
	
	
	Если ДобавляемыеЧасти.Найти("Минута") <> Неопределено
		И СтруктураДаты.Свойство("Минута") Тогда
		ИсходнаяДата = ИсходнаяДата + (СтруктураДаты.Минута * 60);
	КонецЕсли;
	
	Если ДобавляемыеЧасти.Найти("Секунда") <> Неопределено
		И СтруктураДаты.Свойство("Секунда") Тогда
		ИсходнаяДата = ИсходнаяДата + СтруктураДаты.Секунда;
	КонецЕсли;
	
	Возврат ИсходнаяДата;
	
КонецФункции

// Функция - Время даты
//
// Параметры:
//  ИсходнаяДата - Дата - Дата, от которой нужно "отделить" время
// 
// Возвращаемое значение:
//  Дата - Дата, в формате Дата(1, 1, 1, Час, Минута, Секунда), где элементы времени получены из исходной даты
//
Функция ВремяДаты(Знач ИсходнаяДата) Экспорт
	
	Время = Дата(1, 1, 1) + (ИсходнаяДата - НачалоДня(ИсходнаяДата));
	
	Возврат Время;
	
КонецФункции

// Функция - Это високосный год
//
// Параметры:
//  Дата - Дата - 
// 
// Возвращаемое значение:
//  Булево - Истина, если год високосный
//
Функция ЭтоВисокосныйГод(Дата) Экспорт

	Если ДеньГода(КонецГода(Дата)) = 366 Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// Функция - Создает структуру, содержащую части даты
//
// Параметры:
//  Дата - Дата - 
// 
// Возвращаемое значение:
//  Структура -
//		* Год - Число
//		* Месяц - Число
//		* День - Число
//		* Час - Число
//		* Минута - Число
//		* Секунда - Число
//
Функция СтруктураДаты(Дата) Экспорт
	
	Структура = Новый Структура;
	Структура.Вставить("Год", 1);
	Структура.Вставить("Месяц", 1);
	Структура.Вставить("День", 1);
	Структура.Вставить("Час", 0);
	Структура.Вставить("Минута", 0);
	Структура.Вставить("Секунда", 0);
	
	Если ТипЗнч(Дата) = Тип("Дата") Тогда
		
		Структура.Год = Год(Дата);
		Структура.Месяц = Месяц(Дата);
		Структура.День = День(Дата);
		Структура.Час = Час(Дата);
		Структура.Минута = Минута(Дата);
		Структура.Секунда = Секунда(Дата);
		
	КонецЕсли;
	
	Возврат Структура;
	
КонецФункции

#КонецОбласти
