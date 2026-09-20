-- 1. экспорт меню (исправленный с выводом)
create or replace procedure export_menu_to_json(
    p_file_name varchar2 default 'menu_export.json'
) as 
    v_file utl_file.file_type;
    v_json clob;
    v_chunk varchar2(32767);
    v_offset number := 1;
    v_chunk_size number := 32000;
begin
    select json_arrayagg(
        json_object(
            'dish_id' value d.dish_id,
            'dish_name' value d.dish_name,
            'category_name' value c.category_name,
            'price' value d.price,
            'composition' value d.composition,
            'weight' value d.weight,
            'is_available' value d.is_available,
            'is_seasonal' value d.is_seasonal
            returning clob
        )
        returning clob
    ) into v_json
    from dishes d
    join dish_categories c on d.category_id = c.category_id;
    
    if v_json is null then 
        v_json := '[]';
    end if;
    
    v_file := utl_file.fopen('JSON_EXPORT_DIR', p_file_name, 'w', 32767);
    
    while v_offset <= length(v_json) loop
        v_chunk := substr(v_json, v_offset, v_chunk_size);
        utl_file.put(v_file, v_chunk);
        v_offset := v_offset + v_chunk_size;
    end loop;
    
    utl_file.fclose(v_file);
    dbms_output.put_line('экспорт меню выполнен: ' || p_file_name);
exception
    when utl_file.invalid_path then
        if utl_file.is_open(v_file) then
            utl_file.fclose(v_file);
        end if;
        dbms_output.put_line('ошибка: неверный путь к директории JSON_EXPORT_DIR');
        raise;
    when others then
        if utl_file.is_open(v_file) then
            utl_file.fclose(v_file);
        end if;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end export_menu_to_json;
/

-- 2. импорт меню 
create or replace procedure import_menu_from_json(
    p_file_name varchar2 default 'menu_import.json'
) as
    v_file utl_file.file_type;--файл
    v_line varchar2(32767);
    v_json clob;
    v_inserted number := 0;
    v_updated number := 0;
    v_category_id number;
    
    cursor c_dishes is
        select dish_name, category_name, price, composition, weight, is_available, is_seasonal
        from json_table(v_json, '$[*]' columns (--перебираем все данные
            dish_name nvarchar2(100) path '$.dish_name',
            category_name nvarchar2(50) path '$.category_name',
            price number path '$.price',
            composition nvarchar2(500) path '$.composition',
            weight number path '$.weight',
            is_available number path '$.is_available',
            is_seasonal number path '$.is_seasonal'
        ));
begin
    -- читаем файл
    v_file := utl_file.fopen('JSON_EXPORT_DIR', p_file_name, 'r', 32767);
    v_json := '';
    begin
        loop
            utl_file.get_line(v_file, v_line);
            v_json := v_json || v_line;
        end loop;
    exception
        when no_data_found then
            null;
    end;
    utl_file.fclose(v_file);
    
    -- проверяем, что не пустой
    if v_json is null or length(v_json) < 3 then
        dbms_output.put_line('ошибка: файл ' || p_file_name || ' пуст или не содержит данных');
        return;
    end if;
    
    -- импортируем блюда
    for dish in c_dishes loop
        -- находим или создаём категорию
        begin
            select category_id into v_category_id
            from dish_categories
            where category_name = dish.category_name;
        exception
            when no_data_found then
                insert into dish_categories (category_name)
                values (dish.category_name)
                returning category_id into v_category_id;
        end;
        
        -- вставляем или обновляем блюдо
        begin
            insert into dishes (dish_name, category_id, price, composition, weight, is_available, is_seasonal)
            values (dish.dish_name, v_category_id, dish.price, dish.composition, dish.weight, dish.is_available, dish.is_seasonal);
            v_inserted := v_inserted + 1;
        exception
            when dup_val_on_index then
                update dishes set
                    category_id = v_category_id,
                    price = dish.price,
                    composition = dish.composition,
                    weight = dish.weight,
                    is_available = dish.is_available,
                    is_seasonal = dish.is_seasonal
                where dish_name = dish.dish_name;
                v_updated := v_updated + 1;
        end;
    end loop;
    
    commit;
    dbms_output.put_line('импорт меню: вставлено ' || v_inserted || ', обновлено ' || v_updated);
exception
    when utl_file.invalid_path then
        if utl_file.is_open(v_file) then
            utl_file.fclose(v_file);
        end if;
        rollback;
        dbms_output.put_line('ошибка: неверный путь к директории JSON_EXPORT_DIR');
        raise;
    when others then
        if utl_file.is_open(v_file) then
            utl_file.fclose(v_file);
        end if;
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end import_menu_from_json;
/
