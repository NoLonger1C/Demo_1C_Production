
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	СтрокаСоединения = "localhost/Demo/hs/testver1";	

КонецПроцедуры

&НаКлиенте
Процедура КомандаGET(Команда)
	
	КомандаGETНаСервере();

КонецПроцедуры

&НаСервере
Процедура КомандаGETНаСервере()
	
	
	Соединение = ПолучитьСоединение();
	Запрос = Новый HTTPЗапрос("/"+СтрокаЗапроса,ПолучитьЗаголовкиЗапроса());
	Результат = Соединение.Получить(Запрос);
	
	Сообщить(Результат.КодСостояния);
	Для Каждого Элемент Из Результат.Заголовки Цикл
		Сообщить(элемент.Ключ+" : "+Элемент.Значение);
	КонецЦикла;
	СтрокаОтвет = Результат.ПолучитьТелоКакСтроку();
	Сообщить(СтрокаОтвет);	
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаPOST(Команда)
	
	КомандаPOSTНаСервере();	
	
КонецПроцедуры

&НаСервере
Процедура КомандаPOSTНаСервере()

Соединение = ПолучитьСоединение();
	
	//{
    //"from": "1С",
    //"test": "Yes"
	//}
	
	СтрОтве = Новый Структура("from,test","1C","Yes");
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON,СтрОтве);
	СтрОтвет = ЗаписьJSON.Закрыть();
	
	Запрос = Новый HTTPЗапрос("/"+СтрокаЗапроса,ПолучитьЗаголовкиЗапроса());
	Запрос.Заголовки.Вставить("Content-type","application/json");
	Запрос.УстановитьТелоИзСтроки(СтрОтвет);
	Результат = Соединение.ОтправитьДляОбработки(Запрос);
	
	Сообщить(Результат.КодСостояния);
	Для Каждого Элемент Из Результат.Заголовки Цикл
		Сообщить(элемент.Ключ+" : "+Элемент.Значение);
	КонецЦикла;
	СтрокаОтвет = Результат.ПолучитьТелоКакСтроку();
	Сообщить(СтрокаОтвет);
		
КонецПроцедуры

&НаСервере
Функция ПолучитьСоединение()
	
	//localhost/Demo/hs/testver1 
	Попытка
		HTTPСоединение = Новый HTTPСоединение(СтрокаСоединения,,"",);
	Исключение
		ЗаписьЖурналаРегистрации("HTTPСоединение",УровеньЖурналаРегистрации.Ошибка,
			,СтрокаСоединения,ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат HTTPСоединение
		
КонецФункции 

&НаСервере
Функция ПолучитьЗаголовкиЗапроса()

	Заголовки = Новый Соответствие;
	СтрокаBase64 = Base64Строка(ПолучитьДвоичныеДанныеИзСтроки(СтрШаблон("%1:%2", "Администратор", "")));
	СтрокаBase64 = СтрЗаменить(СтрокаBase64, Символы.ПС, "");
	СтрокаBase64 = СтрЗаменить(СтрокаBase64, Символы.ВК, "");
	Заголовки.Вставить("Authorization", СтрШаблон("Basic %1", СтрокаBase64));

	Возврат Заголовки 

КонецФункции // \()

