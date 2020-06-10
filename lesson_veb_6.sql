
-- hometask veb 6
use vk_new;
-- 2. Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

-- по ощущениям перемудрила
select firstname, lastname from users 
where id = (
select from_user_id from messages where 
from_user_id in (
(select ini_user_id from friends_requests
where target_user_id = 3 and status like 'acc%')
union
(select target_user_id from friends_requests
where ini_user_id = 3 and status like 'acc%')
) and to_user_id = 3
group by from_user_id 
order by count(*) desc 
limit 1);

-- 3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
-- я считаю пользователей, которые поставили, а не получили

CREATE TEMPORARY TABLE `10_youngest_users` 
select user_id from profiles 
order by birthday desc limit 10;

select count(*) from likes
where who_likes in (select user_id from `10_youngest_users` 
);

-- 4. Определить кто больше поставил лайков (всего) - мужчины или женщины?



select gender as 'gender_put_more_likes', sum((select count(*) from likes 
where who_likes = profiles.user_id 
group by who_likes)) as 'likes_count'
from profiles
group by gender 
order by 'likes_count' desc limit 1;

-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.


-- вариант 1
select id, 
(select count(*) from posts where creator_id = users.id) +
(select count(*) from media where uploader_id = users.id) + 
(select count(*) from messages where from_user_id = users.id) +
(select count(*) from likes where who_likes = users.id) as 'total_activity'
from users 
order by 'total_activity' limit 10 -- не сортирует по total_activity, сортирует только по id

-- вариант 2
select 
id, 
(select count(*) from posts where creator_id = users.id) as 'p',
(select count(*) from media where uploader_id = users.id) as 'md', 
(select count(*) from messages where from_user_id = users.id) as 'ms',
(select count(*) from likes where who_likes = users.id) as 'l',
'p' + 'md' + 'ms' + 'l' as 'total_activity' -- total activity = 0 
from users 
order by 'total_activity' 
-- total activity считает как 0. В чем ошибка? Почему во втором варианте total activity = 0, а в первом нормально считает? 
-- Спасибо!
