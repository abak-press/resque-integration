# v3.0.1

* 2018-03-20 [ecf1c49](../../commit/ecf1c49) - __(Andrew N. Shalaev)__ Release v3.0.1 
* 2018-03-19 [0837474](../../commit/0837474) - __(Andrew N. Shalaev)__ fix: pass on_failure_retry hook if retry is not defined 
https://jira.railsc.ru/browse/BPC-11091

* 2018-03-19 [eeacf88](../../commit/eeacf88) - __(Andrew N. Shalaev)__ feature: spec on missing superclass for on_failure_retry 
* 2018-03-16 [e57b3bd](../../commit/e57b3bd) - __(Michail Merkushin)__ Release 3.0.0 
* 2018-02-22 [bd45620](../../commit/bd45620) - __(Andrew N. Shalaev)__ fix: keep meta_id on_failure_retry callback if Resque::DirtyExit occurred 
https://jira.railsc.ru/browse/BPC-10431

* 2018-01-25 [927f57e](../../commit/927f57e) - __(Dmitry Bochkarev)__ fix: включение логирования в джобах 
https://jira.railsc.ru/browse/PC4-21241
https://github.com/abak-press/pulscen/pull/16402#issuecomment-360086865

* 2018-01-22 [27b7b31](../../commit/27b7b31) - __(Dmitry Bochkarev)__ feature: обновление resque, resque-scheduler 
https://jira.railsc.ru/browse/PC4-21241

resque-scheduler требует версию resque >= 1.26

* 2017-12-21 [1073796](../../commit/1073796) - __(Dmitry Bochkarev)__ Release 2.0.0 
https://github.com/abak-press/pulscen/releases/tag/20171220

* 2017-12-18 [dd2f2c5](../../commit/dd2f2c5) - __(Michail Merkushin)__ fix: Properly encode lock's args with Hashes 
https://jira.railsc.ru/browse/GOODS-1001

* 2017-12-11 [b0adbfa](../../commit/b0adbfa) - __(Michail Merkushin)__ feat: Add task for expire all resque locks 
https://jira.railsc.ru/browse/PC4-21159

* 2017-12-11 [8eab793](../../commit/8eab793) - __(Nikolay Kondratyev)__ Release 1.18.0 
* 2017-12-10 [9339287](../../commit/9339287) - __(Michail Merkushin)__ fix: Expire unique lock unless it deleted 
https://jira.railsc.ru/browse/PC4-21159

* 2017-12-08 [cdc53a0](../../commit/cdc53a0) - __(Michail Merkushin)__ chore: Refactor. Remove ugly monkey patching. Remove gem resque-lock. 
https://jira.railsc.ru/browse/PC4-21159

* 2017-11-01 [0bd7ab2](../../commit/0bd7ab2) - __(Simeon Movchan)__ Release 1.17.0 
* 2017-10-31 [6d011ea](../../commit/6d011ea) - __(Simeon Movchan)__ feat: warning levels support in queues monitoring 
https://jira.railsc.ru/browse/SERVICES-2051

* 2017-10-23 [deec7c2](../../commit/deec7c2) - __(Andrew N. Shalaev)__ Release v1.16.4 
* 2017-10-23 [3b1cff6](../../commit/3b1cff6) - __(Andrew N. Shalaev)__ feature: optional constraint for resque job_status route 
* 2017-09-11 [2de30b3](../../commit/2de30b3) - __(Andrew N. Shalaev)__ Release v1.16.3 
* 2017-09-11 [7902ea0](../../commit/7902ea0) - __(Andrew N. Shalaev)__ Revert "feature: test of Resque::DirtyExit exception for uniq worker with retry" 
This reverts commit d3d423f549a3b5015741d71a56a26ff9f840e970.

* 2017-09-11 [3b55c58](../../commit/3b55c58) - __(Andrew N. Shalaev)__ Revert "fix: keep meta_id on_failure_retry callback if Resque::DirtyExit occurred" 
This reverts commit 1ff2f4eb5839a5d6da61f0c7d47e0a697954cd3c.

* 2017-09-07 [ddfaf30](../../commit/ddfaf30) - __(korotaev)__ Release 1.16.2 
* 2017-09-06 [92531ff](../../commit/92531ff) - __(korotaev)__ fix(controller): disable browser cache 
https://jira.railsc.ru/browse/GOODS-819

* 2017-09-04 [c47c07d](../../commit/c47c07d) - __(Dmitry Bochkarev)__ Release 1.16.1 
* 2017-09-04 [949023c](../../commit/949023c) - __(Dmitry Bochkarev)__ fix: использоание параметров по умолчанию 
* 2017-09-04 [6ae1c1f](../../commit/6ae1c1f) - __(Dmitry Bochkarev)__ fix: использование канала по умолчанию 
* 2017-08-31 [07c8f53](../../commit/07c8f53) - __(Andrew N. Shalaev)__ Release v1.16.0 
* 2017-08-31 [1ff2f4e](../../commit/1ff2f4e) - __(Andrew N. Shalaev)__ fix: keep meta_id on_failure_retry callback if Resque::DirtyExit occurred 
https://jira.railsc.ru/browse/BPC-10431

* 2017-08-31 [d3d423f](../../commit/d3d423f) - __(Andrew N. Shalaev)__ feature: test of Resque::DirtyExit exception for uniq worker with retry 
* 2017-08-01 [e6d9605](../../commit/e6d9605) - __(Nikolay Kondratyev)__ test: remove duplicated requiring 
* 2017-08-01 [743bd72](../../commit/743bd72) - __(Nikolay Kondratyev)__ test: eliminate deprecation warnings 
* 2017-07-18 [d4485c4](../../commit/d4485c4) - __(Dmitry Bochkarev)__ Release 1.15.0 
Опрос статуса джоба перенесен из приложения на sinatra в контроллер.
Добавлена возможность передавать в хэлпер job_status_url идентификатор
джоба: `job_status_url(meta_id)`.
В проектах необходимо удалить текущее определение роутов
https://github.com/abak-press/pulscen/compare/63988fe...905ed86176dd83f1442e2f745223b23a534ce38b?expand=1#diff-21497849d8f00507c9c8dcaf6288b136L668

* 2017-07-18 [a0913be](../../commit/a0913be) - __(Dmitry Bochkarev)__ fix: добавление в роуты констрейнов 
https://jira.railsc.ru/browse/SERVICES-1909

пришлось переписать тесты, т.к. в 4 рельсах из за констрейнов,
невозможно тестирование провести, без подключения apress-domains с
патченными роутами

* 2017-07-17 [e38bd9d](../../commit/e38bd9d) - __(Dmitry Bochkarev)__ fix: мемоизация меты в контроллере опроса статуса 
https://jira.railsc.ru/browse/SERVICES-1909

* 2017-07-17 [df32bb7](../../commit/df32bb7) - __(Dmitry Bochkarev)__ chore: Appraisals 
* 2017-07-17 [b1c5b8b](../../commit/b1c5b8b) - __(Dmitry Bochkarev)__ feature: контроллер для опроса статуса джобов 
https://jira.railsc.ru/browse/SERVICES-1909

* 2017-07-04 [0b3a1f1](../../commit/0b3a1f1) - __(Semyon Pupkov)__ fix: proper convert hash in args with priority in retry 
* 2017-06-23 [77168c9](../../commit/77168c9) - __(Semyon Pupkov)__ fix: proper implementation for allow dequeue job (#106) 
- Remove meta, meta should be only in unique job
- Save priority value in args for allowing dequeue job

https://jira.railsc.ru/browse/USERS-421
* 2017-06-21 [2d6bcef](../../commit/2d6bcef) - __(Semyon Pupkov)__ feature: allow to use priority queues (#105) 
https://jira.railsc.ru/browse/USERS-421
* 2017-04-24 [d2fb358](../../commit/d2fb358) - __(Michail Merkushin)__ Release 1.14.1 
* 2017-04-24 [ffa3563](../../commit/ffa3563) - __(Michail Merkushin)__ fix: Always schedule to specific queue 
https://jira.railsc.ru/browse/PC4-19474

* 2017-04-24 [26f7955](../../commit/26f7955) - __(Michail Merkushin)__ chore: Upgrade dev configs 
* 2017-04-04 [069a809](../../commit/069a809) - __(Sergey Kucher)__ chore: limit resque-scheduler version < 4.2.1 
```
Running `bundle update` will rebuild your snapshot from scratch, using only
the gems in your Gemfile, which may resolve the conflict.
Bundler could not find compatible versions for gem "resque":
  In Gemfile:
    apress-orders was resolved to 7.0.0, which depends on
      resque-integration (>= 1.5.0) was resolved to 1.14.0, which depends on
        resque (= 1.25.2)

    apress-orders was resolved to 7.0.0, which depends on
      resque-integration (>= 1.5.0) was resolved to 1.14.0, which depends on
        resque-scheduler (~> 4.0) was resolved to 4.2.1, which depends on
          resque (~> 1.26)
```

* 2017-03-16 [0ca9c91](../../commit/0ca9c91) - __(Stanislav Gordanov)__ Release 1.14.0 
* 2017-03-16 [68e77da](../../commit/68e77da) - __(Stanislav Gordanov)__ chore: добавит сборку release в drone 
* 2017-03-13 [073c77d](../../commit/073c77d) - __(Stanislav Gordanov)__ feat: добавит пороговые значения в информацию об очередях 
https://jira.railsc.ru/browse/SG-5765
https://jira.railsc.ru/browse/SERVER-3277

* 2017-02-17 [5fc857f](../../commit/5fc857f) - __(Simeon Movchan)__ Release 1.13.0 
* 2017-02-17 [1d07743](../../commit/1d07743) - __(Dmitry Bochkarev)__ fix: интеграция unique и resque-retry(сохраненние числа перезапусков) 
https://jira.railsc.ru/browse/SERVICES-1192

* 2017-02-14 [459f33b](../../commit/459f33b) - __(rolex08)__ feature: add channel for each queue for zabbix 
https://jira.railsc.ru/browse/SG-5633

* 2017-02-14 [64b383d](../../commit/64b383d) - __(Zhidkov Denis)__ feat: add failed resque jobs data for zabbix 
https://jira.railsc.ru/browse/SG-5458
https://jira.railsc.ru/browse/SG-5459

* 2017-02-15 [bbe54c4](../../commit/bbe54c4) - __(Semyon Pupkov)__ Release 1.12.0 
* 2017-02-01 [f01356c](../../commit/f01356c) - __(Semyon Pupkov)__ fix: job not unlock if unique definded with block and hash 
* 2017-02-01 [a87da05](../../commit/a87da05) - __(Semyon Pupkov)__ feature: increase lock timeout for unique jobs (#92) 
https://jira.railsc.ru/browse/USERS-187
* 2017-01-30 [c4961e0](../../commit/c4961e0) - __(Semyon Pupkov)__ chore: add docker 
* 2016-10-03 [18aad28](../../commit/18aad28) - __(Dmitry Bochkarev)__ Release 1.11.0 
* 2016-10-02 [bc14ed7](../../commit/bc14ed7) - __(Denis Erofeev)__ feature: allow erb syntax in schedule file 
Review code for schedule config erb template

* 2016-09-22 [d178ecf](../../commit/d178ecf) - __(Denis Korobicyn)__ Release 1.10.0 
* 2016-09-22 [eb438e4](../../commit/eb438e4) - __(Denis Korobicyn)__ fix: false overall metric + refactoring 
* 2016-08-24 [dfaf158](../../commit/dfaf158) - __(Denis Korobicyn)__ fix: rename threshold methods 
https://jira.railsc.ru/browse/PC4-17798

* 2016-08-22 [e740ba0](../../commit/e740ba0) - __(Denis Korobicyn)__ fix: return threshold in status for zabbix 
https://jira.railsc.ru/browse/PC4-17798

* 2016-08-17 [029459f](../../commit/029459f) - __(Denis Korobicyn)__ feature: status for each queue for zabbtix 
https://jira.railsc.ru/browse/PC4-17798

* 2016-06-14 [4d46356](../../commit/4d46356) - __(Simeon Movchan)__ Release 1.9.0 
* 2016-06-07 [2bc67b8](../../commit/2bc67b8) - __(Mikhail Nelaev)__ fix: disconnect before forking 
https://jira.railsc.ru/browse/SERVICES-1150

* 2016-05-23 [410dee3](../../commit/410dee3) - __(Simeon Movchan)__ Release 1.8.0 
* 2016-05-20 [faa3bed](../../commit/faa3bed) - __(Evgeny Esaulkov)__ feat: allow erb syntax in conf file 
* 2016-05-17 [d262d6e](../../commit/d262d6e) - __(Dmitry Bochkarev)__ fix: запуск GC при завершении работы воркеров 
https://jira.railsc.ru/browse/SERVICES-1092

* 2016-05-06 [0a3bd6a](../../commit/0a3bd6a) - __(Michail Merkushin)__ Release 1.7.0 
* 2016-04-26 [0f598e2](../../commit/0f598e2) - __(Mikhail Nelaev)__ fix: установит правильный бэкэнд, если notifier не включен 
https://jira.railsc.ru/browse/SERVICES-766

* 2016-04-15 [e254f48](../../commit/e254f48) - __(Mikhail Nelaev)__ feature: подавление ошибок resque-retry 
https://jira.railsc.ru/browse/SERVICES-766
https://jira.railsc.ru/browse/SERVICES-656

* 2016-03-03 [745a3a7](../../commit/745a3a7) - __(Artem Napolskih)__ Release 1.6.1 
* 2016-02-29 [990f62e](../../commit/990f62e) - __(Artem Napolskih)__ feat: resque-status now return null when no active jobs 
* 2016-02-16 [d3928bf](../../commit/d3928bf) - __(Artem Napolskih)__ Release 1.6.0 
* 2016-02-15 [966f9e8](../../commit/966f9e8) - __(Artem Napolskih)__ feat: resque-status: oldest job work time 
* 2015-10-30 [1cca357](../../commit/1cca357) - __(Michail Merkushin)__ Release 1.5.3 
* 2015-10-26 [cf350d2](../../commit/cf350d2) - __(Denis Korobitcin)__ fix: allow change name for worker in god 
https://jira.railsc.ru/browse/PC4-15870

* 2015-10-15 [6877d7a](../../commit/6877d7a) - __(Korotaev Danil)__ chore: use resque-scheduler 4.0 
* 2015-10-05 [272ede7](../../commit/272ede7) - __(Korotaev Danil)__ feat: unique args in ordered jobs 
Closes SERVICES-577

* 2015-10-05 [cd1b41d](../../commit/cd1b41d) - __(Michail Merkushin)__ Release 1.5.2 
* 2015-10-05 [5f80ff4](../../commit/5f80ff4) - __(Michail Merkushin)__ Release 1.5.1 
* 2015-09-29 [d26ed6e](../../commit/d26ed6e) - __(Korotaev Danil)__ fix(ordered): remove extra re-enqueues 
* 2015-10-01 [959e494](../../commit/959e494) - __(Denis Korobitcin)__ chore(progress bar view): removed unused variable 
* 2015-09-30 [effbbe1](../../commit/effbbe1) - __(Semyon Pupkov)__ Release 1.5.0 
* 2015-09-30 [e47aff0](../../commit/e47aff0) - __(Semyon Pupkov)__ feature(progress): add progress bar 
https://jira.railsc.ru/browse/PC4-15672

* 2015-09-15 [58ad5f4](../../commit/58ad5f4) - __(Michail Merkushin)__ Release 1.4.0 
* 2015-09-15 [3ca76ed](../../commit/3ca76ed) - __(Michail Merkushin)__ feature: add shuffled queues on worker 
https://jira.railsc.ru/browse/PC4-15507

* 2015-09-14 [f3ac05d](../../commit/f3ac05d) - __(Michail Merkushin)__ Release 1.3.0 
* 2015-09-14 [333cf82](../../commit/333cf82) - __(Michail Merkushin)__ feature: independent meta for ordered jobs 
https://jira.railsc.ru/browse/PC4-15507

* 2015-09-11 [bc27294](../../commit/bc27294) - __(Michail Merkushin)__ Release 1.2.0 
* 2015-09-10 [1daa167](../../commit/1daa167) - __(Michail Merkushin)__ feature: add ordered jobs 
https://jira.railsc.ru/browse/PC4-15507

* 2015-09-01 [29e3085](../../commit/29e3085) - __(Semyon Pupkov)__ Release 1.1.3 
* 2015-09-01 [ab56d96](../../commit/ab56d96) - __(Igor)__ chore(resque helpers): overriding resque helpers to delete deprecated warning messages 
* 2015-08-21 [e07a446](../../commit/e07a446) - __(Semyon Pupkov)__ fix: undefined method `silence_warnings'` for main:Object 
this errors raises in gem resque-reports, if use activesupport
version 3.1.12

But silence_warnings not suspend warnings about `Resque::Helpers` because
resque reports not use warnigns, and this warn still present if use silence_warnings

* 2015-07-09 [555f1f8](../../commit/555f1f8) - __(bibendi)__ Release 1.1.2 
* 2015-07-08 [608be5c](../../commit/608be5c) - __(Simeon Movchan)__ fix: eager_load! application in worker setup 
https://jira.railsc.ru/browse/SERVICES-430

* 2015-03-31 [f28a754](../../commit/f28a754) - __(bibendi)__ Release 1.1.1 
* 2015-03-31 [d7b17da](../../commit/d7b17da) - __(bibendi)__ Remove gem apress-gems 
* 2015-03-31 [618418c](../../commit/618418c) - __(bibendi)__ Run resque-status with CLI arguments 
* 2014-12-15 [10906d6](../../commit/10906d6) - __(bibendi)__ Release 1.1.0 
* 2014-12-15 [0bdc244](../../commit/0bdc244) - __(bibendi)__ update apress-gems to 0.2.0 
* 2014-12-15 [afa473a](../../commit/afa473a) - __(bibendi)__ remove resque-rails 
* 2014-11-28 [3362b5e](../../commit/3362b5e) - __(bibendi)__ Release 1.0.1 
* 2014-11-19 [4713fb2](../../commit/4713fb2) - __(bibendi)__ fix(hooks): verify connections for rails 4x 
* 2014-11-13 [66329ba](../../commit/66329ba) - __(bibendi)__ Release 1.0.0 
* 2014-11-10 [78ffdd9](../../commit/78ffdd9) - __(bibendi)__ add scheduler, retry, multy-job-forks 
* 2014-10-23 [217ab60](../../commit/217ab60) - __(bibendi)__ bump version to 0.4.4 
* 2014-10-23 [ad37905](../../commit/ad37905) - __(bibendi)__ connect to redis if has credentials in config file 
* 2014-04-07 [3f05f83](../../commit/3f05f83) - __(Merkushin)__ bump version to 0.4.3 
* 2014-04-07 [9d07f2e](../../commit/9d07f2e) - __(Merkushin)__ fix(tasks): rotation now depends on environment 
* 2014-04-04 [1888006](../../commit/1888006) - __(Merkushin)__ bump version to 0.4.2 
* 2014-04-04 [e698b35](../../commit/e698b35) - __(Merkushin)__ update gem god to 0.13.4 
* 2014-04-03 [22650e0](../../commit/22650e0) - __(Merkushin)__ bump version to 0.4.1 
* 2014-04-03 [42709d7](../../commit/42709d7) - __(Merkushin)__ fix lookup for Rails const 
* 2014-04-01 [d4edc0c](../../commit/d4edc0c) - __(Merkushin)__ bump version to 0.4.0 
* 2014-04-01 [929e7dc](../../commit/929e7dc) - __(Merkushin)__ отвязка god от релизных папок 
* 2014-01-09 [fb69813](../../commit/fb69813) - __(Merkushin)__ Version bump to 0.3.1 
* 2014-01-09 [dd8679c](../../commit/dd8679c) - __(Merkushin)__ rake task for logs rotation 
* 2013-12-18 [6126234](../../commit/6126234) - __(Merkushin)__ Version bump to 0.3.0 
* 2013-12-18 [16ad62b](../../commit/16ad62b) - __(Merkushin)__ feature(logs): logs rotation 
* 2013-12-12 [32a345d](../../commit/32a345d) - __(Merkushin)__ Version bump to 0.2.11 
* 2013-12-12 [22a4912](../../commit/22a4912) - __(Merkushin)__ fix(god) fast restart with nowait При рестарте не выключаем и включаем god, а подсовываем ему новую конфигу. Теперь при смене конфига больше нет необходимости дожидаться, пока длинные джобы будут завершены и только потом будут (пере)запущены очереди. Есть небольшой минус, глобальные опции, такие как pid_file_directory не будут перечитаны. 
* 2013-12-12 [fb9a497](../../commit/fb9a497) - __(Merkushin)__ chore(git) ignore .idea 
* 2013-09-03 [f9f5d9c](../../commit/f9f5d9c) - __(Alexei Mikhailov)__ Version bump to 0.2.10 
* 2013-09-03 [6cc57ab](../../commit/6cc57ab) - __(Merkushin)__ feature(hooks): reformat process name 
* 2013-09-03 [27feb40](../../commit/27feb40) - __(Меркушин Михаил)__ feature(hooks): детальное название процесса 
Для того, чтобы смотреть в top и сразу понимать, что за джоб жрёт память
* 2013-08-29 [15849c7](../../commit/15849c7) - __(Alexei Mikhailov)__ Version bump to 0.2.9 
* 2013-08-29 [da53254](../../commit/da53254) - __(Alexei Mikhailov)__ Explicitly set BUNDLE_GEMFILE for each worker 
* 2013-07-03 [e4e8432](../../commit/e4e8432) - __(Alexei Mikhailov)__ Bump to version 0.2.8 
* 2013-07-03 [87b113a](../../commit/87b113a) - __(Alexei Mikhailov)__ fix(resque-status): fix multi_json error when it choses ok_json adapter 
* 2013-06-19 [4995e5f](../../commit/4995e5f) - __(Alexei Mikhailov)__ Version bump to 0.2.7 
* 2013-06-19 [9561852](../../commit/9561852) - __(Alexei Mikhailov)__ fix(continuous): keep meta_id unchanged between continuous jobs 
* 2013-06-18 [58a67d8](../../commit/58a67d8) - __(Alexei Mikhailov)__ Version bump to 0.2.6 
* 2013-06-18 [c729cd5](../../commit/c729cd5) - __(Alexei Mikhailov)__ Freeze resque at 1.23.0 
* 2013-06-18 [a8623c3](../../commit/a8623c3) - __(Alexei Mikhailov)__ Version bump to 0.2.5 
* 2013-06-18 [9e2c065](../../commit/9e2c065) - __(Alexei Mikhailov)__ Remove resque-multi-job-forks due to bugs 
* 2013-06-18 [1a71f34](../../commit/1a71f34) - __(Alexei Mikhailov)__ More precise lock key generation 
* 2013-06-18 [3b41525](../../commit/3b41525) - __(Alexei Mikhailov)__ Fixed #33. rake resque:start теперь запускает resque при запущенном god 
* 2013-06-17 [dd4c579](../../commit/dd4c579) - __(Alexei Mikhailov)__ Fixed #34. Workaround for capistrano deploys. 
* 2013-05-22 [89da883](../../commit/89da883) - __(Alexei Mikhailov)__ Version bump to 0.2.4 
* 2013-05-22 [414e467](../../commit/414e467) - __(Alexei Mikhailov)__ Generate lock_id from hash 
* 2013-04-30 [c9507c5](../../commit/c9507c5) - __(Alexei Mikhailov)__ Version bump to 0.2.3 
* 2013-04-30 [00afd0c](../../commit/00afd0c) - __(Alexei Mikhailov)__ Auto-generated config is not changed between releases 
* 2013-04-29 [9d37c1d](../../commit/9d37c1d) - __(Alexei Mikhailov)__ Version bump to 0.2.2 
* 2013-04-29 [a90f674](../../commit/a90f674) - __(Alexei Mikhailov)__ Fixed #29: Turn off Sinatra logging 
* 2013-04-27 [8236ce5](../../commit/8236ce5) - __(Alexei Mikhailov)__ Version bump to 0.2.1 
* 2013-04-27 [2904387](../../commit/2904387) - __(Alexei Mikhailov)__ Backport hooks behaviour from 1.24.1 
* 2013-04-18 [99ed575](../../commit/99ed575) - __(Alexei Mikhailov)__ Version bump to 0.2.0 
* 2013-04-18 [caafd08](../../commit/caafd08) - __(Alexei Mikhailov)__ Fixed #15; Fixed #16; God integration 
* 2013-04-12 [ea17a78](../../commit/ea17a78) - __(Alexei Mikhailov)__ Fixed #14: log errors date/time 
* 2013-04-12 [6adff6e](../../commit/6adff6e) - __(Alexei Mikhailov)__ Fixed broken resque-status 
* 2013-04-11 [7781357](../../commit/7781357) - __(Alexei Mikhailov)__ Bump version to 0.1.6 
* 2013-04-11 [089df13](../../commit/089df13) - __(Alexei Mikhailov)__ Redis options are now passed directly to Redis constructor 
* 2013-04-10 [12f5fc0](../../commit/12f5fc0) - __(Alexei Mikhailov)__ Fixed #12: removed dependency from bundler in resque-status 
* 2013-04-09 [f0f825c](../../commit/f0f825c) - __(Alexei Mikhailov)__ Version bump to 0.1.5 
* 2013-04-09 [7726900](../../commit/7726900) - __(Alexei Mikhailov)__ resque-multi-job-forks recovered + refactoring 
* 2013-04-08 [3ee123e](../../commit/3ee123e) - __(Alexei Mikhailov)__ Version bump to 0.1.4 
* 2013-04-08 [49a2a0b](../../commit/49a2a0b) - __(Alexei Mikhailov)__ Revert reconnect hook for redis-3.x 
* 2013-04-08 [dbd671b](../../commit/dbd671b) - __(Alexei Mikhailov)__ Version bump to 0.1.3 
* 2013-04-08 [10201e4](../../commit/10201e4) - __(Alexei Mikhailov)__ Reestablish redis connection in each new fork 
* 2013-04-05 [5274eeb](../../commit/5274eeb) - __(Alexei Mikhailov)__ Version bump to 0.1.2 
* 2013-04-05 [1cbacab](../../commit/1cbacab) - __(Alexei Mikhailov)__ Parallel workers restart 
* 2013-04-04 [913cbf8](../../commit/913cbf8) - __(Alexei Mikhailov)__ resque-failed-job-mailer integration 
* 2013-04-03 [f0498d4](../../commit/f0498d4) - __(Alexei Mikhailov)__ Continuous jobs functionality 
* 2013-04-03 [d0868bb](../../commit/d0868bb) - __(Alexei Mikhailov)__ Rails resque initializer 
* 2013-04-02 [83fcadb](../../commit/83fcadb) - __(Alexei Mikhailov)__ Version bump to 0.1.0 
* 2013-04-02 [ec7b4e5](../../commit/ec7b4e5) - __(Alexei Mikhailov)__ Конфигурирование переменных окружения 
* 2013-04-02 [7e065be](../../commit/7e065be) - __(Merkushin)__ fix typo in file name 
* 2013-04-02 [dcca754](../../commit/dcca754) - __(Merkushin)__ fix typo in file name 
* 2013-04-01 [5a7c801](../../commit/5a7c801) - __(Alexei Mikhailov)__ Uniquiness functions extracted to separate module 
* 2013-03-28 [f9c47e6](../../commit/f9c47e6) - __(Alexei Mikhailov)__ Initial commit 
* 2013-03-28 [a2410e6](../../commit/a2410e6) - __(Alexei Mikhailov)__ Initial commit 
