
#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Организация = УТЗ_ПЛ_Организации.СсылкаОрганизацииУТЗ();
	Ответственный = Пользователи.ТекущийПользователь();
	ВидПутевогоЛиста = Перечисления.УТЗ_ПЛ_ВидыПутевыхЛистов.Легковой;
	ДатаВремяУбытия = ДатаВремяУбытияПоУмолчанию();
	ВидСообщения = Перечисления.УТЗ_ПЛ_ВидыТранспортныхСообщений.Городское;
	
	// ===================================================================================================
	// Создание на основании заявки на легковой автотранспорт
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт") Тогда
		СоздатьПутевойЛистНаОснованииЗаявкиНаЛегковойАвтотранспорт(ДанныеЗаполнения);
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт") Тогда
		СоздатьПутевойЛистНаОснованииЗаявкиНаГрузовойАвтотранспорт(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ОтражениеДвиженийПробегАвтотранспорта(Отказ, РежимПроведения);
	// ОтражениеДвиженийВремяРасстояниеМеждуПунктами(Отказ, РежимПроведения);
	ОтражениеДвиженийМоточасыАвтотранспорта(Отказ, РежимПроведения);
	ОтражениеДвиженийОстаткиТоплива(Отказ, РежимПроведения);
	ОтражениеДвиженийТопливоКПоступлению(Отказ, РежимПроведения);
	ОтражениеДвиженийТопливоКСписанию(Отказ, РежимПроведения);
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДатаВремяУбытияПоУмолчанию()
	
	ВремяНачалаРаботы = Дата(1, 1, 1, 8, 0, 0);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних.ВремяНачалаРаботы КАК ВремяНачалаРаботы
	|ИЗ
	|	РегистрСведений.УТЗ_ПЛ_НастройкиПутевыхЛистов.СрезПоследних(&ДатаАктуальности, ) КАК УТЗ_ПЛ_НастройкиПутевыхЛистовСрезПоследних";
	
	Запрос.УстановитьПараметр("ДатаАктуальности", ТекущаяДатаСеанса());
	
	Результат = Запрос.Выполнить();
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ВремяНачалаРаботы = Выборка.ВремяНачалаРаботы;
	КонецЕсли;
	
	Возврат УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(НачалоДня(ТекущаяДатаСеанса()), ВремяНачалаРаботы, "Час, Минута");
	
КонецФункции

#Область ОтражениеДвижений

Процедура ОтражениеДвиженийПробегАвтотранспорта(Отказ, РежимПроведения)
	
	Движения.УТЗ_ПЛ_ПробегАвтотранспорта.Записывать = Истина;
	
	Пробег = ПробегПриПрибытии - ПробегПриУбытии;
	Движение = Движения.УТЗ_ПЛ_ПробегАвтотранспорта.ДобавитьПриход();
	Движение.Период = Дата;
	Движение.Автотранспорт = ОсновнойАвтотранспорт;
	Движение.Ответственный = Ответственный;
	Движение.Количество = Пробег;
	
КонецПроцедуры

Процедура ОтражениеДвиженийВремяРасстояниеМеждуПунктами(Отказ, РежимПроведения)
	
	Для Каждого Строка Из Маршрут Цикл
		
		ОшибкаЗаполненияКлючевыхПолей = Не ЗначениеЗаполнено(Строка.ПунктУбытия) 
										Или	Не ЗначениеЗаполнено(Строка.ПунктПрибытия) 
										Или Не ЗначениеЗаполнено(Строка.ВремяВПути)
										Или Не ЗначениеЗаполнено(Строка.Расстояние);
		
		// Если не заполнены ключевые поля строки, то ничего не делаем
		Если ОшибкаЗаполненияКлючевыхПолей Тогда
			Продолжить;
		КонецЕсли;
		
		Менеджер = РегистрыСведений.УТЗ_ПЛ_ВремяРасстояниеМеждуПунктами.СоздатьМенеджерЗаписи();
		Менеджер.Автотранспорт = ОсновнойАвтотранспорт;
		Менеджер.Пункт1 = Строка.ПунктУбытия;
		Менеджер.Пункт2 = Строка.ПунктПрибытия;
		Менеджер.Прочитать();
		
		Если Не Менеджер.Выбран() Тогда
			Менеджер.Автотранспорт = ОсновнойАвтотранспорт;
			Менеджер.Пункт1 = Строка.ПунктУбытия;
			Менеджер.Пункт2 = Строка.ПунктПрибытия;
		КонецЕсли;
		
		Менеджер.Время = Строка.ВремяВПути;
		Менеджер.Расстояние = Строка.Расстояние;
		
		Менеджер.Записать(Истина);
	КонецЦикла;
	
КонецПроцедуры

Процедура ОтражениеДвиженийМоточасыАвтотранспорта(Отказ, РежимПроведения)
	
	Движения.УТЗ_ПЛ_МоточасыАвтотранспорта.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ПутевойЛистМоточасы.Автотранспорт КАК Автотранспорт,
	|	СУММА(УТЗ_ПЛ_ПутевойЛистМоточасы.Количество) КАК Количество,
	|	МАКСИМУМ(УТЗ_ПЛ_ПутевойЛистМоточасы.Ссылка.Дата) КАК Период,
	|	МАКСИМУМ(УТЗ_ПЛ_ПутевойЛистМоточасы.Ссылка.Ответственный) КАК Ответственный
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.Моточасы КАК УТЗ_ПЛ_ПутевойЛистМоточасы
	|ГДЕ
	|	УТЗ_ПЛ_ПутевойЛистМоточасы.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	УТЗ_ПЛ_ПутевойЛистМоточасы.Автотранспорт";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Движение = Движения.УТЗ_ПЛ_МоточасыАвтотранспорта.Добавить();
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОтражениеДвиженийОстаткиТоплива(Отказ, РежимПроведения)
	
	Движения.УТЗ_ПЛ_ОстаткиТоплива.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Автотранспорт КАК Автотранспорт,
	|	СУММА(УТЗ_ПЛ_ПутевойЛистПриходТоплива.Количество) КАК Количество,
	|	МАКСИМУМ(УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка.Дата) КАК Период,
	|	МАКСИМУМ(УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка.Ответственный) КАК Ответственный
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.ПриходТоплива КАК УТЗ_ПЛ_ПутевойЛистПриходТоплива
	|ГДЕ
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Автотранспорт";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	// Отражаем приход для контроля остатков
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.УТЗ_ПЛ_ОстаткиТоплива.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
	КонецЦикла;
	Движения.УТЗ_ПЛ_ОстаткиТоплива.Записать();
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.ОсновнойАвтотранспорт КАК Автотранспорт,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.Дата КАК Период,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.ФактическийРасходТоплива КАК Количество,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.Ответственный КАК Ответственный
	|ПОМЕСТИТЬ ВТРасходТоплива
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.Маршрут КАК УТЗ_ПЛ_ПутевойЛистМаршрут
	|ГДЕ
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка = &Ссылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Автотранспорт,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка.Дата,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.РасходФакт,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка.Ответственный
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.ДополнительныйРасходТоплива КАК УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива
	|ГДЕ
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТРасходТоплива.Автотранспорт КАК Автотранспорт,
	|	МАКСИМУМ(ВТРасходТоплива.Период) КАК Период,
	|	СУММА(ВТРасходТоплива.Количество) КАК Количество,
	|	МАКСИМУМ(ВТРасходТоплива.Ответственный) КАК Ответственный
	|ПОМЕСТИТЬ ВТСгруппированныйРасход
	|ИЗ
	|	ВТРасходТоплива КАК ВТРасходТоплива
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТРасходТоплива.Автотранспорт";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Выполнить();
	
	// Формируем источники блокировки (Сине-Никольский А.А.)
	ТЗИсточникБлокировки = Запрос.МенеджерВременныхТаблиц.Таблицы["ВТСгруппированныйРасход"].ПолучитьДанные().Выгрузить();
	ТЗИсточникБлокировки.Свернуть("Автотранспорт");
	
	// Ставим блокировку (Сине-Никольский А.А.)
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.УТЗ_ПЛ_ОстаткиТоплива");
	ЭлементБлокировки.ИсточникДанных = ТЗИсточникБлокировки;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Автотранспорт", "Автотранспорт");
	Блокировка.Заблокировать();
	
	// получаем границу, чтобы считать остатки с учетом приходов по этому же документу (Сине-Никольский А.А.)
	Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВТСгруппированныйРасход.Автотранспорт КАК Автотранспорт,
	|	ВТСгруппированныйРасход.Период КАК Период,
	|	ВТСгруппированныйРасход.Количество КАК Количество,
	|	ВТСгруппированныйРасход.Ответственный КАК Ответственный,
	|	ЕСТЬNULL(УТЗ_ПЛ_ОстаткиТопливаОстатки.КоличествоОстаток, 0) КАК ОстатокТоплива
	|ИЗ
	|	ВТСгруппированныйРасход КАК ВТСгруппированныйРасход
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.УТЗ_ПЛ_ОстаткиТоплива.Остатки(
	|				&МоментВремени,
	|				Автотранспорт В
	|					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|						ВТСгруппированныйРасход.Автотранспорт КАК Автотранспорт
	|					ИЗ
	|						ВТСгруппированныйРасход КАК ВТСгруппированныйРасход)) КАК УТЗ_ПЛ_ОстаткиТопливаОстатки
	|		ПО ВТСгруппированныйРасход.Автотранспорт = УТЗ_ПЛ_ОстаткиТопливаОстатки.Автотранспорт";
	Запрос.УстановитьПараметр("МоментВремени", Граница);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	// Формирование движений и контроль остатков (Сине-Никольский А.А.)
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.Количество > Выборка.ОстатокТоплива Тогда
			Отказ = Истина;
			ТекстСообщения = СтрШаблон("Ошибка списания топлива. Расход топлива превышает наличие с учетом заправок."
			+ Символы.ПС 
			+ "Требуется списать %1 л., имеется %2 л.",  
			Выборка.Количество,
			Выборка.ОстатокТоплива);
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		КонецЕсли;
		
		Движение = Движения.УТЗ_ПЛ_ОстаткиТоплива.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОтражениеДвиженийТопливоКПоступлению(Отказ, РежимПроведения)
	
	Движения.УТЗ_ПЛ_ТопливоКПоступлению.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка КАК ДокументПоступления,
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Топливо.Номенклатура КАК Номенклатура,
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.ТопливнаяКарта.СкладERP КАК Склад,
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка.ПодразделениеВладелец КАК Подразделение,
	|	СУММА(УТЗ_ПЛ_ПутевойЛистПриходТоплива.Количество) КАК КоличествоКПриемке
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.ПриходТоплива КАК УТЗ_ПЛ_ПутевойЛистПриходТоплива
	|ГДЕ
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка,
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Топливо.Номенклатура,
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.ТопливнаяКарта.СкладERP,
	|	УТЗ_ПЛ_ПутевойЛистПриходТоплива.Ссылка.ПодразделениеВладелец";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Движение = Движения.УТЗ_ПЛ_ТопливоКПоступлению.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(Движение, ВыборкаДетальныеЗаписи);
		Движение.Период = Дата;
	КонецЦикла;
	
КонецПроцедуры

Процедура ОтражениеДвиженийТопливоКСписанию(Отказ, РежимПроведения)
	
	Движения.УТЗ_ПЛ_ТопливоКСписанию.Записывать = Истина;
	Движения.УТЗ_ПЛ_ТопливоКСписанию.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.Дата КАК Период,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка КАК ДокументСписания,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.ОсновнойАвтотранспорт.Топливо.Номенклатура КАК Номенклатура,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.ПодразделениеЗаявитель КАК Подразделение,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.ТопливнаяКарта.СкладERP КАК Склад,
	|	СУММА(УТЗ_ПЛ_ПутевойЛистМаршрут.ФактическийРасходТоплива) КАК КоличествоКСписанию
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.Маршрут КАК УТЗ_ПЛ_ПутевойЛистМаршрут
	|
	|СГРУППИРОВАТЬ ПО
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.Дата,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.Ссылка.ОсновнойАвтотранспорт.Топливо.Номенклатура,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.ПодразделениеЗаявитель,
	|	УТЗ_ПЛ_ПутевойЛистМаршрут.ТопливнаяКарта.СкладERP
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДОБАВИТЬКДАТЕ(УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка.Дата, СЕКУНДА, -1),
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Автотранспорт.Топливо.Номенклатура,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.ПодразделениеЗаявитель,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.ТопливнаяКарта.СкладERP,
	|	СУММА(УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.РасходФакт)
	|ИЗ
	|	Документ.УТЗ_ПЛ_ПутевойЛист.ДополнительныйРасходТоплива КАК УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива
	|ГДЕ
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	ДОБАВИТЬКДАТЕ(УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка.Дата, СЕКУНДА, -1),
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Ссылка,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.Автотранспорт.Топливо.Номенклатура,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.ПодразделениеЗаявитель,
	|	УТЗ_ПЛ_ПутевойЛистДополнительныйРасходТоплива.ТопливнаяКарта.СкладERP";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.УТЗ_ПЛ_ТопливоКСписанию.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СозданиеНаОсновании

Процедура СоздатьПутевойЛистНаОснованииЗаявкиНаЛегковойАвтотранспорт(ДанныеЗаполнения)
	
	Если ТипЗнч(ДанныеЗаполнения) <> Тип("ДокументСсылка.УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт") Тогда 
		
		ОбщегоНазначения.СообщитьПользователю("Попытка создания легкового путевого листа не"  
		+ "на основании заявки на легковой автотранспорт");
		Возврат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.Водитель КАК Водитель,
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.Ссылка КАК Автотранспорт
	|ПОМЕСТИТЬ ВТОсновнойВодитель
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт.СписокВодителей КАК УТЗ_ПЛ_АвтотранспортСписокВодителей
	|ГДЕ
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.ЭтоОсновнойВодитель
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПРЕДСТАВЛЕНИЕ(УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Ссылка) КАК ПредставлениеЗаявки,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Номер КАК Номер,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Дата КАК Дата,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.ПодразделениеЗаявитель КАК ПодразделениеЗаявитель,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Автотранспорт КАК Автотранспорт,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Ответственный КАК Ответственный,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.МаршрутСледования.(
	|		ПунктНазначения КАК ПунктНазначения,
	|		ДатаПодачи КАК ДатаПодачи,
	|		ВремяПодачи КАК ВремяПодачи,
	|		ВремяВозврата КАК ВремяВозврата,
	|		Примечание КАК Примечание,
	|		Контакты КАК Контакты
	|	) КАК МаршрутСледования,
	|	ЕСТЬNULL(ВТОсновнойВодитель.Водитель, ЗНАЧЕНИЕ(Справочник.УТЗ_ПЛ_Водители.ПустаяСсылка)) КАК Водитель,
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Автотранспорт.ПодразделениеВладелец КАК ПодразделениеВладелец
	|ИЗ
	|	Документ.УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт КАК УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТОсновнойВодитель КАК ВТОсновнойВодитель
	|		ПО УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Автотранспорт = ВТОсновнойВодитель.Автотранспорт
	|ГДЕ
	|	УТЗ_ПЛ_ЗаявкаНаЛегковойАвтотранспорт.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	// ===================================================================================================
	// Заполняем шапку документа. Остатки топлива и пробег получим после расчета даты убытия
	
	Основание               = ДанныеЗаполнения;
	ВидПутевогоЛиста        = Перечисления.УТЗ_ПЛ_ВидыПутевыхЛистов.Легковой;
	ВидСообщения            = Перечисления.УТЗ_ПЛ_ВидыТранспортныхСообщений.Городское;
	Водитель                = Выборка.Водитель;
	Организация             = УТЗ_ПЛ_Организации.СсылкаОрганизацииУТЗ();
	ОсновнойАвтотранспорт   = Выборка.Автотранспорт;
	Ответственный           = Пользователи.ТекущийПользователь();
	ПодразделениеВладелец   = Выборка.ПодразделениеВладелец;
	Комментарий 			= СтрШаблон("Создано на основании ""%1""", Выборка.ПредставлениеЗаявки);
	// ===================================================================================================
	// Заполняем табличную часть "Маршрут"
	
	ВыборкаМаршрут = Выборка.МаршрутСледования.Выбрать();
	
	Если ВыборкаМаршрут.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ЭтоПерваяСтрока = Истина;
	ИндексСтроки = -1;
	
	ВремяНачалаРаботы = УТЗ_ПЛ_НастройкиПутевыхЛистов.ВремяНачалаРаботы();
	
	ДатаВремяУбытия = Дата(1, 1, 1);
	
	Пока ВыборкаМаршрут.Следующий() Цикл 
		
		ИндексСтроки = ИндексСтроки + 1;
		
		// В заявке указываются только пункты назначения, соответственно 
		// факт перемещения из гаража заявкой не определяются. 
		// Принимается, что если время подачи в заявке больше 08:00, то в путевом листе временем убытия будет 08:00
		// Иначе время убытия в путевом листе устанавливается часом ранее первого времени подачи в заявке	
		Если ЭтоПерваяСтрока Тогда // рассчитываем дату, время убытия и дополнительно создаем строку гараж -> пункт назначения
			
			Если ВыборкаМаршрут.ВремяПодачи > ВремяНачалаРаботы Тогда 
				ВремяУбытия = ВремяНачалаРаботы;
			Иначе 
				ВремяУбытия = Дата(1, 1, 1) + (ВыборкаМаршрут.ВремяПодачи - Дата(1, 1, 1, 1, 0, 0));
			КонецЕсли;
			
			ПерваяСтрока = Маршрут.Добавить();
			
			ЭтоПерваяСтрока = Ложь;
			
			ПерваяСтрока.НулевойПробег = Истина;
			ПерваяСтрока.ДатаВремяУбытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер
												.СуммаДат(НачалоДня(ВыборкаМаршрут.ДатаПодачи), 
														  ВремяУбытия,
														  "Час, Минута");
														  
			ПерваяСтрока.ВремяВПути = Дата(1, 1, 1) + (ВыборкаМаршрут.ВремяПодачи - ВремяУбытия);
			ПерваяСтрока.ДатаВремяПрибытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер
												.СуммаДат(ПерваяСтрока.ДатаВремяУбытия,
														  ПерваяСтрока.ВремяВПути, 
														  "Час, Минута");
			ПерваяСтрока.ПодразделениеЗаявитель = Выборка.ПодразделениеЗаявитель;											  
			ПерваяСтрока.ПунктУбытия = УТЗ_ПЛ_НастройкиПутевыхЛистов.ТекущееМестоПарковкиЛегковогоАвтотранспорта();
			ПерваяСтрока.ПунктПрибытия = ВыборкаМаршрут.ПунктНазначения;
			
			ДатаВремяУбытия = ПерваяСтрока.ДатаВремяУбытия;
			ПробегПриУбытии = УТЗ_ПЛ_Автотранспорт.ПробегАвтотранспортаНаДату(Выборка.Автотранспорт, ДатаВремяУбытия);
			ПробегПриПрибытии = ПробегПриУбытии;
			ОстатокТопливаПриУбытии = УТЗ_ПЛ_Автотранспорт
										.ОстатокТопливаАвтотранспортаНаДату(Выборка.Автотранспорт, ДатаВремяУбытия);
			ОстатокТопливаПриПрибытии = ОстатокТопливаПриУбытии;
			
			ПерваяСтрока.ПробегПриУбытии = ПробегПриУбытии;
		
		Иначе
		
			НоваяСтрока = Маршрут.Добавить();									
		
			ПредыдущаяСтрока = Маршрут.Получить(ИндексСтроки - 1);
		
			НоваяСтрока.ПодразделениеЗаявитель = Выборка.ПодразделениеЗаявитель;
			НоваяСтрока.ПунктУбытия = ПредыдущаяСтрока.ПунктПрибытия;
			НоваяСтрока.ПунктПрибытия = ВыборкаМаршрут.ПунктНазначения;
			НоваяСтрока.ДатаВремяУбытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(НачалоДня(ВыборкаМаршрут.ДатаПодачи), 
																				   ВыборкаМаршрут.ВремяПодачи,
																				   "Час, Минута");
			НоваяСтрока.ДатаВремяПрибытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(НачалоДня(ВыборкаМаршрут.ДатаПодачи), 
																				   ВыборкаМаршрут.ВремяВозврата,
																				   "Час, Минута");
			НоваяСтрока.ВремяВПути = Дата(1, 1, 1) + (НоваяСтрока.ДатаВремяПрибытия - НоваяСтрока.ДатаВремяУбытия);
		
			ВремяОжиданияНаПунктеПрибытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.ВремяДаты(ПредыдущаяСтрока.ДатаВремяПрибытия);

			БылоОжиданиеВПунктеНазначения = ВыборкаМаршрут.ВремяПодачи <> ВремяОжиданияНаПунктеПрибытия;
					
			Если БылоОжиданиеВПунктеНазначения Тогда // рассчитываем и записываем величину ожидания в предыдущую строку
				ВремяОжидания = Дата(1, 1, 1) + (ВыборкаМаршрут.ВремяПодачи - ВремяОжиданияНаПунктеПрибытия);
				ПредыдущаяСтрока.ВремяОжиданияНаПунктеПрибытия = ВремяОжидания;
			КонецЕсли;
		КонецЕсли;
	
	КонецЦикла;
	
	ПредыдущаяСтрока = Маршрут.Получить(Маршрут.Количество() - 1);
	ДатаВремяПрибытия = ПредыдущаяСтрока.ДатаВремяПрибытия;
	
КонецПроцедуры

Процедура СоздатьПутевойЛистНаОснованииЗаявкиНаГрузовойАвтотранспорт(ДанныеЗаполнения)
	
	Если ТипЗнч(ДанныеЗаполнения) <> Тип("ДокументСсылка.УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт") Тогда 
		
		ОбщегоНазначения.СообщитьПользователю("Попытка создания легкового путевого листа не"  
		+ "на основании заявки на грузовой автотранспорт");
		Возврат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.Водитель КАК Водитель,
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ ВТОсновныеВодители
	|ИЗ
	|	Справочник.УТЗ_ПЛ_Автотранспорт.СписокВодителей КАК УТЗ_ПЛ_АвтотранспортСписокВодителей
	|ГДЕ
	|	УТЗ_ПЛ_АвтотранспортСписокВодителей.ЭтоОсновнойВодитель
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПРЕДСТАВЛЕНИЕ(УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Ссылка) КАК ПредставлениеЗаявки,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.ПодразделениеЗаявитель КАК ПодразделениеЗаявитель,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Автотранспорт КАК Автотранспорт,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Грузоотправитель КАК Грузоотправитель,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Грузополучатель КАК Грузополучатель,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.ПунктПогрузки КАК ПунктПогрузки,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.ПунктНазначения КАК ПунктНазначения,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.ДатаВремяПогрузки КАК ДатаВремяПогрузки,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.ДатаВремяРазгрузки КАК ДатаВремяРазгрузки,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Ответственный КАК Ответственный,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Комментарий КАК Комментарий,
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Автотранспорт.ПодразделениеВладелец КАК ПодразделениеВладелец,
	|	ЕСТЬNULL(ВТОсновныеВодители.Водитель, ЗНАЧЕНИЕ(Справочник.УТЗ_ПЛ_Водители.ПустаяСсылка)) КАК Водитель
	|ИЗ
	|	Документ.УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт КАК УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТОсновныеВодители КАК ВТОсновныеВодители
	|		ПО УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Автотранспорт = ВТОсновныеВодители.Ссылка
	|ГДЕ
	|	УТЗ_ПЛ_ЗаявкаНаГрузовойАвтотранспорт.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	// ===================================================================================================
	// Заполнение шапки таблицы
	Основание = ДанныеЗаполнения;
	Ответственный = Пользователи.ТекущийПользователь();
	Комментарий = СтрШаблон("Создано на основании ""%1""", Выборка.ПредставлениеЗаявки);
	Организация = УТЗ_ПЛ_Организации.СсылкаОрганизацииУТЗ();
	ОсновнойАвтотранспорт = Выборка.Автотранспорт;
	Водитель = Выборка.Водитель;
	ПодразделениеВладелец = Выборка.ПодразделениеВладелец;
	ВидСообщения = Перечисления.УТЗ_ПЛ_ВидыТранспортныхСообщений.Городское;
	ВидПутевогоЛиста = Перечисления.УТЗ_ПЛ_ВидыПутевыхЛистов.Грузовой;
	ПробегПриУбытии = УТЗ_ПЛ_Автотранспорт.ПробегАвтотранспортаНаДату(ОсновнойАвтотранспорт, Выборка.ДатаВремяПогрузки);
	ОстатокТопливаПриУбытии = УТЗ_ПЛ_Автотранспорт.ОстатокТопливаАвтотранспортаНаДату(ОсновнойАвтотранспорт, 
																					  Выборка.ДатаВремяПогрузки);
	ПробегПриПрибытии = ПробегПриУбытии;
	ОстатокТопливаПриПрибытии = ОстатокТопливаПриУбытии;
	ДатаВремяПрибытия = Выборка.ДатаВремяРазгрузки;
	
	// ===================================================================================================
	// Расчитываем дату и время убытия. Если время разгрузки после 08:00, то время ставим 08:00,
	// если раньше, то на час раньше от даты разгрузки
	ВремяПогрузкиПоЗаявке = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.ВремяДаты(Выборка.ДатаВремяПогрузки);
	ВремяНачалаРаботы = УТЗ_ПЛ_НастройкиПутевыхЛистов.ВремяНачалаРаботы();
	
	Если ВремяПогрузкиПоЗаявке > ВремяНачалаРаботы Тогда
		ВремяУбытия = ВремяНачалаРаботы;
	Иначе
		ВремяУбытия = Дата(1, 1, 1) + (ВремяНачалаРаботы - Дата(1, 1, 1, 1, 0, 0));
	КонецЕсли;
	
	ДатаВремяУбытия = УТЗ_ПЛ_ОбщегоНазначенияКлиентСервер.СуммаДат(НачалоДня(Выборка.ДатаВремяПогрузки),
																   ВремяУбытия, 
																   "Час, Минута");
	// ===================================================================================================
	// Заполнение табличной части "Маршрут"
	
	// Нулевая строка - от гаража до пункта погрузки
	НулеваяСтрока = Маршрут.Добавить();
	НулеваяСтрока.НулевойПробег = Истина;
	НулеваяСтрока.ПодразделениеЗаявитель = Выборка.ПодразделениеЗаявитель;
	НулеваяСтрока.ПунктУбытия = УТЗ_ПЛ_НастройкиПутевыхЛистов.ТекущееМестоПарковкиГрузовогоАвтотранспорта();
	НулеваяСтрока.ПунктПрибытия = Выборка.ПунктПогрузки;
	НулеваяСтрока.ПробегПриУбытии = ПробегПриУбытии;
	НулеваяСтрока.ДатаВремяУбытия = ДатаВремяУбытия;
	НулеваяСтрока.ДатаВремяПрибытия = Выборка.ДатаВремяПогрузки;
	НулеваяСтрока.ВремяВПути = Дата(1, 1, 1) + (НулеваяСтрока.ДатаВремяПрибытия - НулеваяСтрока.ДатаВремяУбытия);
	
	// Основная строка - пункт погрузки -> пункт назначения
	ОсновнаяСтрока = Маршрут.Добавить();
	ОсновнаяСтрока.ПодразделениеЗаявитель = Выборка.ПодразделениеЗаявитель;
	ОсновнаяСтрока.ПунктУбытия = НулеваяСтрока.ПунктПрибытия;
	ОсновнаяСтрока.ДатаВремяУбытия = НулеваяСтрока.ДатаВремяПрибытия;
	ОсновнаяСтрока.ПунктУбытия = НулеваяСтрока.ПунктПрибытия;
	ОсновнаяСтрока.ПунктПрибытия = Выборка.ПунктНазначения;
	ОсновнаяСтрока.ДатаВремяПрибытия = Выборка.ДатаВремяРазгрузки;
	ОсновнаяСтрока.ВремяВПути = Дата(1, 1, 1) + (ОсновнаяСтрока.ДатаВремяПрибытия - ОсновнаяСтрока.ДатаВремяУбытия);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
