// Процедура на основании анализа типа данных заменяет их на данные, удаляющие
// информацию из узла в котором их не должно быть
//
// Параметры:
//  Данные	– Объект, набор записей,... который нужно преобразовать
//
Процедура УдалениеДанных(Данные) 
	
	// Получаем объект описания метаданного, соответствующий данным
	ОбъектМетаданных = ?(ТипЗнч(Данные) = Тип("УдалениеОбъекта"), Данные.Ссылка.Метаданные(), Данные.Метаданные());
    // Проверяем тип, интересуют только те типы, которые реализованы на мобильной платформе
	Если Метаданные.Справочники.Содержит(ОбъектМетаданных)
	 	ИЛИ Метаданные.Документы.Содержит(ОбъектМетаданных) Тогда
		
		// Перенос удаления объекта для объектных
		Данные = Новый УдалениеОбъекта(Данные.Ссылка);
		
	ИначеЕсли Метаданные.РегистрыСведений.Содержит(ОбъектМетаданных)
		ИЛИ Метаданные.РегистрыНакопления.Содержит(ОбъектМетаданных)
		ИЛИ Метаданные.Последовательности.Содержит(ОбъектМетаданных) Тогда
		
		// Очищаем данные
		Данные.Очистить();
		
	КонецЕсли;	
	
КонецПроцедуры

Функция СформироватьXML(УзелОбмена)
    
	УстановитьПривилегированныйРежим(Истина);
	ЗаписьXML = Новый ЗаписьXML;
	
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();
    
	ЗаписьСообщения = ПланыОбмена.СоздатьЗаписьСообщения();
    ЗаписьСообщения.НачатьЗапись(ЗаписьXML, УзелОбмена);					
    
	ЗаписьXML.ЗаписатьСоответствиеПространстваИмен("xsi", "http://www.w3.org/2001/XMLSchema-instance");
	ЗаписьXML.ЗаписатьСоответствиеПространстваИмен("v8",  "http://v8.1c.ru/data");
    
	ТипДанныхУдаления = Тип("УдалениеОбъекта");
    
	ВыборкаИзменений = ПланыОбмена.ВыбратьИзменения(УзелОбмена, ЗаписьСообщения.НомерСообщения);
	Пока ВыборкаИзменений.Следующий() Цикл
		
		Данные = ВыборкаИзменений.Получить();
        
		// Если перенос данных не нужен, то, возможно, необходимо записать удаление данных
		Если НЕ ОбменМобильныеПереопределяемый.НуженПереносДанных(Данные, УзелОбмена) Тогда
			
			// Получаем значение с возможным удалением данных
			УдалениеДанных(Данные); 
            
		КонецЕсли;	
		
		// Записываем данные в сообщение
		ОбменМобильныеПереопределяемый.ЗаписатьДанные(ЗаписьXML, Данные);
        
    КонецЦикла;
    
	ЗаписьСообщения.ЗакончитьЗапись();
	
	Возврат ЗаписьXML.Закрыть();
	
КонецФункции

// Функция формирует пакет обмена, который будет отправлен узлу "УзелОбмена" 
//
// Параметры:
//  УзелОбмена	– узел плана обмена "мобильные", с которым осуществляется обмен
//
// Возвращаемое значение:
//  сформированный пакет, помещенный в хранилище значения
Функция СформироватьПакетОбмена(УзелОбмена) Экспорт
	
	Пакет = СформироватьXML(УзелОбмена);
	Возврат Новый ХранилищеЗначения(Пакет, Новый СжатиеДанных(9));
    
КонецФункции

// Процедура вносит в информационную базу данные, которые присланы из узла "УзелОбмена" 
//
// Параметры:
//  УзелОбмена	– узел плана обмена "мобильные", с которым осуществляется обмен
//  ДанныеОбмена - пакет обмена полученный из узла УзелОбмена, помещен в ХранилищеЗначения
//
Процедура ПринятьПакетОбмена(УзелОбмена, ДанныеОбмена) Экспорт
    
	УстановитьПривилегированныйРежим(Истина);
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(ДанныеОбмена.Получить());
    ЧтениеСообщения = ПланыОбмена.СоздатьЧтениеСообщения();
	ЧтениеСообщения.НачатьЧтение(ЧтениеXML);
    ПланыОбмена.УдалитьРегистрациюИзменений(ЧтениеСообщения.Отправитель,ЧтениеСообщения.НомерПринятого);

    НачатьТранзакцию();
    Пока ВозможностьЧтенияXML(ЧтениеXML) Цикл
        
		Данные = ОбменМобильныеПереопределяемый.ПрочитатьДанные(ЧтениеXML);
        
		Если НЕ Данные = Неопределено Тогда
			
            Данные.ОбменДанными.Отправитель = ЧтениеСообщения.Отправитель;
            Данные.ОбменДанными.Загрузка = Истина;
            
            Данные.Записать();
        
        КонецЕсли;
        
    КонецЦикла;
    ЗафиксироватьТранзакцию();
    
    ЧтениеСообщения.ЗакончитьЧтение();
    ЧтениеXML.Закрыть();
    
КонецПроцедуры
