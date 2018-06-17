/*!
 * Star Rating Russian Translations
 *
 * This file must be loaded after 'star-rating.js'. Patterns in braces '{}', or
 * any HTML markup tags in the messages must not be converted or translated.
 *
 * NOTE: this file must be saved in UTF-8 encoding.
 *
 * @see http://github.com/kartik-v/bootstrap-star-rating
 * @author Kartik Visweswaran <kartikv2@gmail.com>
 * @author Ivan Zhuravlev.
 */
(function ($) {
    "use strict";
    $.fn.ratingLocales['ru'] = {
        defaultCaption: '{rating} Звёзды',
        starCaptions: {
            0.5: 'Половина звезды',
            1: 'Очень плохо',
            1.5: 'Полторы звезды',
            2: 'Плохо',
            2.5: 'Две с половиной звезды',
            3: 'Удовлетворительно',
            3.5: 'Три с половиной звезды',
            4: 'Хорошо',
            4.5: 'Четыре с половиной звезды',
            5: 'Отлично'
        },
        clearButtonTitle: 'Очистить',
        clearCaption: 'Без рейтинга'
    };
})(window.jQuery);
