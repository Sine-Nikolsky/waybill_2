#Область ПрограммныйИнтерфейс

// Функция - Пробег автотранспорта на дату по списку
//
// Параметры:
//  СписокАвтотранспорта - Массив<СправочникСсылка.УТЗ_ПЛ_Автотранспорт> - список автотранспорта 
//  ДатаАктуальности	 - Дата - Дата, на которую необходимо получить значения пробегов
// 
// Возвращаемое значение:
//  Соответствие -
//		Ключ - СправочникСсылка.УТЗ_ПЛ_Автотранспорт
//		Значение - число - пробег автотранспорта
//
Функция ПробегАвтотранспортаНаДатуПоСписку(СписокАвтотранспорта, ДатаАктуальности = Неопределено) Экспорт
	
	Если ДатаАктуальности = Неопределено Тогда
		ДатаАктуальности = ТекущаяДатаСеанса();
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ ВТСписокАвтотранспорта
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт КАК УТЗ_ПЛ_Автотранспорт
	|ГДЕ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка В(&СписокАвтотранспорта)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	УТЗ_ПЛ_ПробегАвтотранспортаОстатки.Автотранспорт КАК Автотранспорт,
	|	УТЗ_ПЛ_ПробегАвтотранспортаОстатки.КоличествоОстаток КАК Пробег
	|ПОМЕСТИТЬ ВТПробеги
	|ИЗ
	|	РегистрНакопления.УТЗ_ПЛ_ПробегАвтотранспорта.Остатки(&ДатаАктуальности, Автотранспорт В (&СписокАвтотранспорта)) КАК УТЗ_ПЛ_ПробегАвтотранспортаОстатки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТСписокАвтотранспорта.Ссылка КАК Автотранспорт,
	|	ЕСТЬNULL(ВТПробеги.Пробег, 0) КАК Пробег
	|ИЗ
	|	ВТСписокАвтотранспорта КАК ВТСписокАвтотранспорта
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПробеги КАК ВТПробеги
	|		ПО ВТСписокАвтотранспорта.Ссылка = ВТПробеги.Автотранспорт";
	
	Запрос.УстановитьПараметр("СписокАвтотранспорта", СписокАвтотранспорта);
	Запрос.УстановитьПараметр("ДатаАктуальности", ДатаАктуальности);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Ответ = Новый Соответствие;
	Пока Выборка.Следующий() Цикл
		Ответ.Вставить(Выборка.Автотранспорт, Выборка.Пробег);
	КонецЦикла;
	
	Возврат Ответ;
	
КонецФункции

// Функция - Пробег автотранспорта на дату по списку
//
// Параметры:
//  Автотранспорт - СправочникСсылка.УТЗ_ПЛ_Автотранспорт - Автотранспорт
//  ДатаАктуальности	 - Дата - Дата, на которую необходимо получить значения пробегов
// 
// Возвращаемое значение:
//  Число - пробег автотранспорта на дату
//
Функция ПробегАвтотранспортаНаДату(Автотранспорт, ДатаАктуальности = Неопределено) Экспорт
	
	СписокАвтотранспорта = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Автотранспорт);
	Сведения = ПробегАвтотранспортаНаДатуПоСписку(СписокАвтотранспорта, ДатаАктуальности);
	
	Пробег = 0;
	
	Для Каждого КлючЗначение Из Сведения Цикл 
		Пробег = КлючЗначение.Значение;
	КонецЦикла;
	
	Возврат Пробег;
	
КонецФункции

// Функция - Сведения об автотранспорте на дату по списку
//
// Параметры:
//  СписокАвтотранспорта - Массив - Массив элементов типа СправочникСсылка.УТЗ_ПЛ_Автотранспорт 
//  ДатаАктуальности	 - Дата - Дата, на которую необходимо получить сведения 
// 
// Возвращаемое значение:
//  Соответствие:
//		Ключ - СправочникСсылка.УТЗ_ПЛ_Автотранспорт
//		Значение - Структура:
//						* ВидАвтотранспорта	- ПеречислениеСсылка.УТЗ_ПЛ_ВидыАвтотранспорта
//						* Модель - СправочникСсылка.УТЗ_ПЛ_МоделиАвтотранспорта
//						* ВидПутевогоЛиста - ПеречислениеСсылка.УТЗ_ПЛ_ВидыПутевыхЛистов
//						* ДатаВводаВЭксплуатацию - Дата
//						* Возраст - Число
//						* ОсновнойВодитель - СправочникСсылка.УТЗ_ПЛ_Водители
//						* ПодразделениеВладелец - СправочникСсылка.СтруктураПредприятия
//						* Топливо - СправочникСсылка.УТЗ_ПЛ_Топливо
//						* Пробег - Число
//						* ОстатокТоплива - Число
//						* НормаРасходаОсновная - Число
//						* НормаРасходаДополнительнаяНаПеревозку - Число
//						* Моточасы - Число
Функция СведенияОбАвтотранспортеНаДатуПоСписку(СписокАвтотранспорта, ДатаАктуальности = Неопределено) Экспорт
	
	Если ДатаАктуальности = Неопределено Тогда
		ДатаАктуальности = ТекущаяДатаСеанса();
	КонецЕсли;
	
	СписокБезДубликатов = ОбщегоНазначенияКлиентСервер.СвернутьМассив(СписокАвтотранспорта);
	
	СтруктураОтвета = Новый Структура;
	
	СтруктураОтвета.Вставить("Автотранспорт", Справочники.УТЗ_ПЛ_Автотранспорт.ПустаяСсылка());
	СтруктураОтвета.Вставить("ВидАвтотранспорта", Перечисления.УТЗ_ПЛ_ВидыАвтотранспорта.ПустаяСсылка());
	СтруктураОтвета.Вставить("Модель", Справочники.УТЗ_ПЛ_МоделиАвтотранспорта.ПустаяСсылка());
	СтруктураОтвета.Вставить("ВидПутевогоЛиста", Перечисления.УТЗ_ПЛ_ВидыПутевыхЛистов.Легковой);
	СтруктураОтвета.Вставить("ДатаВводаВЭксплуатацию", Дата(1, 1, 1));
	СтруктураОтвета.Вставить("Возраст", 0);
	СтруктураОтвета.Вставить("ОсновнойВодитель", Справочники.УТЗ_ПЛ_Водители.ПустаяСсылка());
	СтруктураОтвета.Вставить("ПодразделениеВладелец", Справочники.СтруктураПредприятия.ПустаяСсылка());
	СтруктураОтвета.Вставить("Топливо", Справочники.УТЗ_ПЛ_Топливо.ПустаяСсылка());
	СтруктураОтвета.Вставить("Пробег", 0);
	СтруктураОтвета.Вставить("ОстатокТоплива", 0);
	СтруктураОтвета.Вставить("НормаРасходаОсновная", 0);
	СтруктураОтвета.Вставить("НормаРасходаДополнительнаяНаПеревозку", 0);
	СтруктураОтвета.Вставить("Моточасы", 0);

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.Ссылка КАК Ссылка,
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.Водитель КАК Водитель
	|ПОМЕСТИТЬ ВТОсновныеВодители
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт.СписокВодителей КАК УТЗ_ПЛ_АвтотранспортСписокВодителей
	|ГДЕ
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.ЭтоОсновнойВодитель
	|	И УТЗ_ПЛ_АвтотранспортСписокВодителей.Ссылка В(&СписокАвтотранспорта)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка КАК Ссылка,
	|	УТЗ_ПЛ_Автотранспорт.ВидАвтотранспорта КАК ВидАвтотранспорта,
	|	УТЗ_ПЛ_Автотранспорт.Модель КАК Модель,
	|	УТЗ_ПЛ_Автотранспорт.ВидПутевогоЛистаПоУмолчанию КАК ВидПутевогоЛиста,
	|	УТЗ_ПЛ_Автотранспорт.ДатаВводаВЭксплуатацию КАК ДатаВводаВЭксплуатацию,
	|	ВЫБОР
	|		КОГДА УТЗ_ПЛ_Автотранспорт.ДатаВводаВЭксплуатацию = ДАТАВРЕМЯ(1, 1, 1)
	|			ТОГДА 0
	|		ИНАЧЕ РАЗНОСТЬДАТ(УТЗ_ПЛ_Автотранспорт.ДатаВводаВЭксплуатацию, &ДатаАктуальности, ГОД)
	|	КОНЕЦ КАК Возраст,
	|	УТЗ_ПЛ_Автотранспорт.ПодразделениеВладелец КАК ПодразделениеВладелец,
	|	УТЗ_ПЛ_Автотранспорт.Топливо КАК Топливо,
	|	ЕСТЬNULL(ВТОсновныеВодители.Водитель, ЗНАЧЕНИЕ(Справочник.УТЗ_ПЛ_Водители.ПустаяСсылка)) КАК ОсновнойВодитель
	|ПОМЕСТИТЬ ВТСписокАвтотранспорта
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт КАК УТЗ_ПЛ_Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТОсновныеВодители КАК ВТОсновныеВодители
	|		ПО УТЗ_ПЛ_Автотранспорт.Ссылка = ВТОсновныеВодители.Ссылка
	|ГДЕ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка В(&СписокАвтотранспорта)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ВТОсновныеВодители
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТСписокАвтотранспорта.Ссылка КАК Автотранспорт,
	|	ВТСписокАвтотранспорта.ВидАвтотранспорта КАК ВидАвтотранспорта,
	|	ВТСписокАвтотранспорта.Модель КАК Модель,
	|	ВТСписокАвтотранспорта.ВидПутевогоЛиста КАК ВидПутевогоЛиста,
	|	ВТСписокАвтотранспорта.ДатаВводаВЭксплуатацию КАК ДатаВводаВЭксплуатацию,
	|	ВТСписокАвтотранспорта.Возраст КАК Возраст,
	|	ВТСписокАвтотранспорта.ПодразделениеВладелец КАК ПодразделениеВладелец,
	|	ВТСписокАвтотранспорта.Топливо КАК Топливо,
	|	ВТСписокАвтотранспорта.ОсновнойВодитель КАК ОсновнойВодитель,
	|	ЕСТЬNULL(УТЗ_ПЛ_МоточасыАвтотранспортаОбороты.КоличествоОборот, 0) КАК Моточасы,
	|	ЕСТЬNULL(УТЗ_ПЛ_ОстаткиТопливаОстатки.КоличествоОстаток, 0) КАК ОстатокТоплива,
	|	ЕСТЬNULL(УТЗ_ПЛ_ПробегАвтотранспортаОстатки.КоличествоОстаток, 0) КАК Пробег,
	|	ЕСТЬNULL(УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних.НормаРасходаОсновная, 0) КАК НормаРасходаОсновная,
	|	ЕСТЬNULL(УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних.НормаРасходаДополнительнаяНаПеревозку, 0) КАК НормаРасходаДополнительнаяНаПеревозку
	|ИЗ
	|	ВТСписокАвтотранспорта КАК ВТСписокАвтотранспорта
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.УТЗ_ПЛ_МоточасыАвтотранспорта.Обороты(, , , Автотранспорт В (&СписокАвтотранспорта)) КАК УТЗ_ПЛ_МоточасыАвтотранспортаОбороты
	|		ПО ВТСписокАвтотранспорта.Ссылка = УТЗ_ПЛ_МоточасыАвтотранспортаОбороты.Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.УТЗ_ПЛ_ОстаткиТоплива.Остатки(&ДатаАктуальности, Автотранспорт В (&СписокАвтотранспорта)) КАК УТЗ_ПЛ_ОстаткиТопливаОстатки
	|		ПО ВТСписокАвтотранспорта.Ссылка = УТЗ_ПЛ_ОстаткиТопливаОстатки.Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.УТЗ_ПЛ_ПробегАвтотранспорта.Остатки(&ДатаАктуальности, Автотранспорт В (&СписокАвтотранспорта)) КАК УТЗ_ПЛ_ПробегАвтотранспортаОстатки
	|		ПО ВТСписокАвтотранспорта.Ссылка = УТЗ_ПЛ_ПробегАвтотранспортаОстатки.Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.УТЗ_ПЛ_НормыРасходаТопливаАвтотранспорта.СрезПоследних(&ДатаАктуальности, Автотранспорт В (&СписокАвтотранспорта)) КАК УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних
	|		ПО ВТСписокАвтотранспорта.Ссылка = УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних.Автотранспорт";
	
	Запрос.УстановитьПараметр("ДатаАктуальности", ДатаАктуальности);
	Запрос.УстановитьПараметр("СписокАвтотранспорта", СписокБезДубликатов);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Ответ = Новый Соответствие;
	
	Пока Выборка.Следующий() Цикл
		
		ЗаполнитьЗначенияСвойств(СтруктураОтвета, Выборка, , "Автотранспорт");
		
		Ответ.Вставить(Выборка.Автотранспорт, СтруктураОтвета);
		
	КонецЦикла;
	
	Возврат Ответ;
	
КонецФункции

// Функция - Сведения об автотранспорте на дату
//
// Параметры:
//  Автотранспорт - СправочникСсылка.УТЗ_ПЛ_Автотранспорт  - 
//  ДатаАктуальности	 - Дата - Дата, на которую необходимо получить сведения 
// 
// Возвращаемое значение:
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
Функция СведенияОбАвтотранспортеНаДату(Автотранспорт, ДатаАктуальности = Неопределено) Экспорт	
	
	АвтотранспортВМассиве = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Автотранспорт);
	Сведения = СведенияОбАвтотранспортеНаДатуПоСписку(АвтотранспортВМассиве, ДатаАктуальности);
	
	Ответ = Сведения.Получить(Автотранспорт);
	
	Если Ответ = Неопределено Тогда
		СтруктураОтвета = Новый Структура;
		
		СтруктураОтвета.Вставить("Автотранспорт", Справочники.УТЗ_ПЛ_Автотранспорт.ПустаяСсылка());
		СтруктураОтвета.Вставить("ВидАвтотранспорта", Перечисления.УТЗ_ПЛ_ВидыАвтотранспорта.ПустаяСсылка());
		СтруктураОтвета.Вставить("Модель", Справочники.УТЗ_ПЛ_МоделиАвтотранспорта.ПустаяСсылка());
		СтруктураОтвета.Вставить("ВидПутевогоЛиста", Перечисления.УТЗ_ПЛ_ВидыПутевыхЛистов.Легковой);
		СтруктураОтвета.Вставить("ДатаВводаВЭксплуатацию", Дата(1, 1, 1));
		СтруктураОтвета.Вставить("Возраст", 0);
		СтруктураОтвета.Вставить("ОсновнойВодитель", Справочники.УТЗ_ПЛ_Водители.ПустаяСсылка());
		СтруктураОтвета.Вставить("ПодразделениеВладелец", Справочники.СтруктураПредприятия.ПустаяСсылка());
		СтруктураОтвета.Вставить("Топливо", Справочники.УТЗ_ПЛ_Топливо.ПустаяСсылка());
		СтруктураОтвета.Вставить("Пробег", 0);
		СтруктураОтвета.Вставить("ОстатокТоплива", 0);
		СтруктураОтвета.Вставить("НормаРасходаОсновная", 0);
		СтруктураОтвета.Вставить("НормаРасходаДополнительнаяНаПеревозку", 0);
		СтруктураОтвета.Вставить("Моточасы", 0);
		Ответ = СтруктураОтвета;
	КонецЕсли;
	
	Возврат Ответ;
	
КонецФункции

// Функция - Остаток топлива автотранспорта на дату
//
// Параметры:
//  Автотранспорт	 - СправочникСсылка.УТЗ_ПЛ_Автотранспорт - 
//  ДатаАктуальности - Дата	 - Если не задана, принимается текущая дата
// 
// Возвращаемое значение:
//  Число - Остаток топлива на дату
//
Функция ОстатокТопливаАвтотранспортаНаДату(Автотранспорт, ДатаАктуальности = Неопределено) Экспорт
	
	Если ДатаАктуальности = Неопределено Тогда
		ДатаАктуальности = ТекущаяДатаСеанса();		
	КонецЕсли;
	Запрос = Новый Запрос;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ОстаткиТопливаОстатки.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.УТЗ_ПЛ_ОстаткиТоплива.Остатки(&ДатаАктуальности, Автотранспорт = &Автотранспорт) КАК УТЗ_ПЛ_ОстаткиТопливаОстатки";	
	
	Запрос.УстановитьПараметр("ДатаАктуальности", ДатаАктуальности);
	Запрос.УстановитьПараметр("Автотранспорт", Автотранспорт);
	
	Результат = Запрос.Выполнить();
	
	ОстатокТоплива = 0;
	
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ОстатокТоплива = Выборка.КоличествоОстаток;
	КонецЕсли;
	
	Возврат ОстатокТоплива;
	
КонецФункции

// Функция - Нормативный расход топлива автотранспорта
//
// Параметры:
//  ПараметрыПолучения	 - 	Структура - Параметры, полученные с помощью метода 
//										УТЗ_ПЛ_Автотранспорт.ПараметрыПолученияНормативногоРасходаТоплива
//										* Автотранспорт 				- СправочникСсылка.УТЗ_ПЛ_Автотранспорт
//										* Прицеп						- СправочникСсылка.УТЗ_ПЛ_Автотранспорт
//										* СуммарнаяМассаГруза			- Число
//										* Расстояние					- Число
//										* КоэффициентНаселенногоПункта	- ПеречислениеСсылка.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ
//										* КоэффициентКлассаДороги		- ПеречислениеСсылка.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ
//										* КоэффициентГорнойМестности	- ПеречислениеСсылка.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ (не используется)
//  ДатаАктуальности	 - Дата - Дата актуальности получения данных 
// 
// Возвращаемое значение:
//  Число - нормативный расход автотранспорта
//
Функция НормативныйРасходТопливаАвтотранспорта(ПараметрыПолучения, ДатаАктуальности = Неопределено) Экспорт
	
	// Если ключевые параметры не заданы, тогда ничего не делаем
	Если Не ЗначениеЗаполнено(ПараметрыПолучения.Автотранспорт)
		Или Не ЗначениеЗаполнено(ПараметрыПолучения.Расстояние) Тогда
		Возврат 0;
	КонецЕсли;
	
	Если ДатаАктуальности = Неопределено Тогда 
		ДатаАктуальности = ТекущаяДатаСеанса();
	КонецЕсли;
	
	// Проверяем, нужно ли учитывать прицеп при расчете
	НужноУчитыватьПрицеп = Ложь;
	МассаПрицепа = 0;
	Если ЗначениеЗаполнено(ПараметрыПолучения.Прицеп) Тогда 
		НужноУчитыватьПрицеп = Истина;
		МассаПрицепа = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ПараметрыПолучения.Прицеп, "СобственнаяМасса", Истина);
	КонецЕсли;
	
	// Определяем виды коэффициентов, которые не нужно принимать к расчету из параметров получения. 
	// Если коэффициенты не заполнены, то их и исключаем
	// Параллельно добавляем в массив переданные коэффициенты для удобства
	ИсключаемыеВидыКоэффициентов = Новый Массив;
	ПереданныеКоэффициенты = Новый Массив;
	
	УчитыватьНаселенныйПункт = Истина;
	УчитыватьКлассДороги = Истина;
	
	Если Не ЗначениеЗаполнено(ПараметрыПолучения.КоэффициентНаселенногоПункта) Тогда
		ИсключаемыеВидыКоэффициентов.Добавить(Перечисления.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ.КоэффициентНаселенногоПункта);
		УчитыватьНаселенныйПункт = Ложь;
	Иначе
		ПереданныеКоэффициенты.Добавить(ПараметрыПолучения.КоэффициентНаселенногоПункта);
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ПараметрыПолучения.КоэффициентКлассаДороги) Тогда
		ИсключаемыеВидыКоэффициентов.Добавить(Перечисления.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ.КоэффициентКлассаДороги);
		УчитыватьКлассДороги = Ложь;
	Иначе
		ПереданныеКоэффициенты.Добавить(ПараметрыПолучения.КоэффициентКлассаДороги);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.КоэффициентКондиционера КАК КоэффициентКондиционера,
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.КоэффициентВозрастаПробега1 КАК КоэффициентВозрастаПробега1,
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.КоэффициентВозрастаПробега2 КАК КоэффициентВозрастаПробега2,
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.УчитыватьКлассДороги КАК УчитыватьКлассДороги,
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.УчитыватьРазмерНаселенногоПункта КАК УчитыватьРазмерНаселенногоПункта,
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.УчитыватьВозрастПробег КАК УчитыватьВозрастПробег,
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.УчитыватьКондиционер КАК УчитыватьКондиционер
	|ПОМЕСТИТЬ ВТНастройкиПутевыхЛистов
	|ИЗ
	|	РегистрСведений.УТЗ_ПЛ_НастройкиПутевыхЛистов.СрезПоследних(&ДатаАктуальности, ) КАК УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка КАК Автотранспорт,
	|	РАЗНОСТЬДАТ(УТЗ_ПЛ_Автотранспорт.ДатаВводаВЭксплуатацию, &ДатаАктуальности, ГОД) КАК Возраст,
	|	ЕСТЬNULL(УТЗ_ПЛ_ПробегАвтотранспортаОстатки.КоличествоОстаток, 0) КАК Пробег,
	|	ЕСТЬNULL(УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних.НормаРасходаОсновная, 0) КАК НормаРасходаТоплива,
	|	ЕСТЬNULL(УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних.НормаРасходаДополнительнаяНаПеревозку, 0) КАК НормаРасходаТопливаНаПеревозку,
	|	ЕСТЬNULL(УТЗ_ПЛ_ЗначенияКоэффициентовРасходаТопливаСрезПоследних.Коэффициент, ЗНАЧЕНИЕ(Справочник.УТЗ_ПЛ_КоэффициентыРасходаТоплива.ПустаяСсылка)) КАК Коэффициент,
	|	ЕСТЬNULL(УТЗ_ПЛ_ЗначенияКоэффициентовРасходаТопливаСрезПоследних.Значение, 0) КАК Значение
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт КАК УТЗ_ПЛ_Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.УТЗ_ПЛ_ПробегАвтотранспорта.Остатки(&ДатаАктуальности, Автотранспорт = &Автотранспорт) КАК УТЗ_ПЛ_ПробегАвтотранспортаОстатки
	|		ПО УТЗ_ПЛ_Автотранспорт.Ссылка = УТЗ_ПЛ_ПробегАвтотранспортаОстатки.Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.УТЗ_ПЛ_НормыРасходаТопливаАвтотранспорта.СрезПоследних(&ДатаАктуальности, Автотранспорт = &Автотранспорт) КАК УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних
	|		ПО УТЗ_ПЛ_Автотранспорт.Ссылка = УТЗ_ПЛ_НормыРасходаТопливаАвтотранспортаСрезПоследних.Автотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.УТЗ_ПЛ_ЗначенияКоэффициентовРасходаТоплива.СрезПоследних(
	|				&ДатаАктуальности,
	|				Автотранспорт = &Автотранспорт
	|					И НЕ Коэффициент.ВидКоэффициента В (&ИсключаемыеВидыКоэффициентов)) КАК УТЗ_ПЛ_ЗначенияКоэффициентовРасходаТопливаСрезПоследних
	|		ПО УТЗ_ПЛ_Автотранспорт.Ссылка = УТЗ_ПЛ_ЗначенияКоэффициентовРасходаТопливаСрезПоследних.Автотранспорт
	|ГДЕ
	|	УТЗ_ПЛ_Автотранспорт.Ссылка = &Автотранспорт
	|
	|УПОРЯДОЧИТЬ ПО
	|	Коэффициент
	|ИТОГИ
	|	МАКСИМУМ(Возраст),
	|	МАКСИМУМ(Пробег),
	|	МАКСИМУМ(НормаРасходаТоплива),
	|	МАКСИМУМ(НормаРасходаТопливаНаПеревозку)
	|ПО
	|	Автотранспорт";
	
	Запрос.УстановитьПараметр("Автотранспорт", ПараметрыПолучения.Автотранспорт);
	Запрос.УстановитьПараметр("ДатаАктуальности", ДатаАктуальности);
	Запрос.УстановитьПараметр("ИсключаемыеВидыКоэффициентов", ИсключаемыеВидыКоэффициентов);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат 0;
	КонецЕсли;
	
	Выборка = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Выборка.Следующий();
	ВыборкаКоэффициенты = Выборка.Выбрать();
	
	ВыборкаНастройки = Запрос.МенеджерВременныхТаблиц.Таблицы["ВТНастройкиПутевыхЛистов"].ПолучитьДанные().Выбрать();
	ВыборкаНастройки.Следующий();
	
	// Инициализация переменных для расчета
	КоэффициентКондиционера 			= ВыборкаНастройки.КоэффициентКондиционера;
	КоэффициентВозрастаПробега1 		= ВыборкаНастройки.КоэффициентВозрастаПробега1;
	КоэффициентВозрастаПробега2 		= ВыборкаНастройки.КоэффициентВозрастаПробега2;
	УчитыватьКлассДороги 				= ВыборкаНастройки.УчитыватьКлассДороги;
	УчитыватьВозрастПробег 				= ВыборкаНастройки.УчитыватьВозрастПробег;
	УчитыватьКондиционер 				= ВыборкаНастройки.УчитыватьКондиционер;
	СуммарнаяМассаГруза 				= ПараметрыПолучения.СуммарнаяМассаГруза;
	Расстояние 							= ПараметрыПолучения.Расстояние;
	КоэффициентНаселенногоПункта 		= ПараметрыПолучения.КоэффициентНаселенногоПункта;
	КоэффициентКлассаДороги 			= ПараметрыПолучения.КоэффициентКлассаДороги;
	НормаРасходаТоплива 				= Выборка.НормаРасходаТоплива;
	НормаРасходаТопливаНаПеревозку 		= Выборка.НормаРасходаТопливаНаПеревозку;
	Пробег								= Выборка.Пробег;
	Возраст								= Выборка.Возраст;
	
	// Определяем коэффициент возраста и пробега исходя полученных данных
	КоэффициентВозрастаПробегаКРасчету = Неопределено;
	
	Если (Возраст >= 5 И Возраст < 8) Или (Пробег >= 100000 И Пробег < 150000) Тогда
		КоэффициентВозрастаПробегаКРасчету = КоэффициентВозрастаПробега1;
	ИначеЕсли Возраст >= 8 Или Пробег >= 150000 Тогда
		КоэффициентВозрастаПробегаКРасчету = КоэффициентВозрастаПробега2;
	Иначе
		КоэффициентВозрастаПробегаКРасчету = Справочники.УТЗ_ПЛ_КоэффициентыРасходаТоплива.ПустаяСсылка();
	КонецЕсли;
	
	ОсновнойРасход = 0;
	ДополнительныйРасходНаПеревозкуГрузов = 0;
	
	// Расчет основного расхода
	ОсновнойРасход = (Расстояние / 100) * НормаРасходаТоплива;
	
	// Расчет дополнительного расхода на перевозку грузов
	Если СуммарнаяМассаГруза <> 0 Или НужноУчитыватьПрицеп Тогда
		
		МассаГрузаКРасчету = СуммарнаяМассаГруза + МассаПрицепа;
		
		// Норма расхода на транспортную работу - это сколько литров дополнительно израсходует автотранспорт 
		// при перевозке 1 тонны груза на 100 км. 
		// Считаем сколько сотен километров был перевезен груз
		СотенКилометров = Расстояние / 100;
		
		// Считаем, сколько тонн груза всего на автотранспорте
		ТоннГруза = МассаГрузаКРасчету / 1000;
		
		// Пример - Считаем, что норма расхода на перевозку 1 тонны на 1 сотню км - 5 литров. Соответственно,
		// перевозка 0,5 тонны на 1 сотню км уменьшит доп.расход вдвое,
		// как и если будет перевезена 1 тонна на 0.5 сотни км., т.е. составит 2.5 л.
		// Если же автотранспорт перевез 0.5 тонн на расстояние 0.5 км, то доп.расход уменьшится еще пропорционально
		// Соответственно формула расчета:
		//	НормаРасхода 	* ТоннГруза * СотенКилометров   = ДопРасход
		//	    5			*	0.5		*	0.5				= 1.25
		ДополнительныйРасходНаПеревозкуГрузов = НормаРасходаТопливаНаПеревозку * СотенКилометров * ТоннГруза;
		
	КонецЕсли;
	
	// Рассчитываем повышающие коэффициенты
	СуммаЗначенийВсехКоэффициентов = 0;
	ИмяПоляОтбора = "Коэффициент";
	ВыборкаКоэффициенты.Сбросить();
	Если УчитыватьНаселенныйПункт
		И ВыборкаКоэффициенты.НайтиСледующий(Новый Структура(ИмяПоляОтбора, КоэффициентНаселенногоПункта)) Тогда
		СуммаЗначенийВсехКоэффициентов = СуммаЗначенийВсехКоэффициентов + ВыборкаКоэффициенты.Значение;
	КонецЕсли;
	
	ВыборкаКоэффициенты.Сбросить();
	Если УчитыватьКлассДороги
		И ВыборкаКоэффициенты.НайтиСледующий(Новый Структура(ИмяПоляОтбора, КоэффициентКлассаДороги)) Тогда
		СуммаЗначенийВсехКоэффициентов = СуммаЗначенийВсехКоэффициентов + ВыборкаКоэффициенты.Значение;
	КонецЕсли;
	
	ВыборкаКоэффициенты.Сбросить();
	Если УчитыватьВозрастПробег
		И ВыборкаКоэффициенты.НайтиСледующий(Новый Структура(ИмяПоляОтбора, КоэффициентВозрастаПробегаКРасчету)) Тогда
		СуммаЗначенийВсехКоэффициентов = СуммаЗначенийВсехКоэффициентов + ВыборкаКоэффициенты.Значение;
	КонецЕсли;
	
	ВыборкаКоэффициенты.Сбросить();
	Если УчитыватьКондиционер
		И ВыборкаКоэффициенты.НайтиСледующий(Новый Структура(ИмяПоляОтбора, КоэффициентКондиционера)) Тогда
		СуммаЗначенийВсехКоэффициентов = СуммаЗначенийВсехКоэффициентов + ВыборкаКоэффициенты.Значение;
	КонецЕсли;
	
	ИтоговыйПовышающийКоэффициент = 1 + (СуммаЗначенийВсехКоэффициентов / 100);
	
	ИтоговыйРасход = (ОсновнойРасход + ДополнительныйРасходНаПеревозкуГрузов) * ИтоговыйПовышающийКоэффициент;
	
	ОкругленныйРасход = Окр(ИтоговыйРасход, 3);
	
	Возврат ОкругленныйРасход;
	
КонецФункции

// Функция - Параметры получения нормативного расхода топлива
// 
// Возвращаемое значение:
//  Структура - 
//			* Автотранспорт - СправочникСсылка.УТЗ_ПЛ_Автотранспорт
//			* Прицеп - СправочникСсылка.УТЗ_ПЛ_Автотранспорт
//			* СуммарнаяМассаГруза - Число
//			* Расстояние - Число
//			* КоэффициентНаселенногоПункта - СправочникСсылка.УТЗ_ПЛ_КоэффициентыРасходаТоплива
//			* КоэффициентКлассаДороги - СправочникСсылка.УТЗ_ПЛ_КоэффициентыРасходаТоплива
//			* (не используется) КоэффициентГорнойМестности - СправочникСсылка.УТЗ_ПЛ_КоэффициентыРасходаТоплива
//
Функция ПараметрыПолученияНормативногоРасходаТоплива() Экспорт
	
	ПараметрыПолучения = Новый Структура;
	ПараметрыПолучения.Вставить("Автотранспорт", Справочники.УТЗ_ПЛ_Автотранспорт.ПустаяСсылка());
	ПараметрыПолучения.Вставить("Прицеп", Справочники.УТЗ_ПЛ_Автотранспорт.ПустаяСсылка());
	ПараметрыПолучения.Вставить("СуммарнаяМассаГруза", 0);
	ПараметрыПолучения.Вставить("Расстояние", 0);
	ПараметрыПолучения.Вставить("КоэффициентНаселенногоПункта", 
								Перечисления.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ.ПустаяСсылка());
	ПараметрыПолучения.Вставить("КоэффициентКлассаДороги", 
								Перечисления.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ.ПустаяСсылка());
	ПараметрыПолучения.Вставить("КоэффициентГорнойМестности", 
								Перечисления.УТЗ_ПЛ_ВидыКоэффициентовРасходаГСМ.ПустаяСсылка());
	
	Возврат ПараметрыПолучения;
	
КонецФункции

#КонецОбласти
