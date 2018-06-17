/*
 * jQuery Form Styler v1.4.8
 * https://github.com/Dimox/jQueryFormStyler
 *
 * Copyright 2012-2014 Dimox (http://dimox.name/)
 * Released under the MIT license.
 *
 * Date: 2014.02.02
 *
 */

(function($) {
	$.fn.styler = function(opt) {

		var opt = $.extend({
			wrapper: 'form',
			idSuffix: '-styler',
			filePlaceholder: '���� �� ������',
			fileBrowse: '�����...',
			selectSearch: true,
			selectSearchLimit: 10,
			selectSearchNotFound: '���������� �� �������',
			selectSearchPlaceholder: '�����...',
			selectVisibleOptions: 0,
			singleSelectzIndex: '100',
			selectSmartPositioning: true
		}, opt);

		return this.each(function() {
			var el = $(this);

			function attributes() {
				var id = '',
						title = '',
						classes = '',
						dataList = '';
				if (el.attr('id') !== undefined && el.attr('id') != '') id = ' id="' + el.attr('id') + opt.idSuffix + '"';
				if (el.attr('title') !== undefined && el.attr('title') != '') title = ' title="' + el.attr('title') + '"';
				if (el.attr('class') !== undefined && el.attr('class') != '') classes = ' ' + el.attr('class');
				var data = el.data();
				for (var i in data) {
					if (data[i] != '') dataList += ' data-' + i + '="' + data[i] + '"';
				}
				id += dataList;
				this.id = id;
				this.title = title;
				this.classes = classes;
			}

			// checkbox
			if (el.is(':checkbox')) {
				el.each(function() {
					if (el.parent('div.jq-checkbox').length < 1) {

						function checkbox() {

							var att = new attributes();
							var checkbox = $('<div' + att.id + ' class="jq-checkbox' + att.classes + '"' + att.title + '><div class="jq-checkbox__div"></div></div>');

							// ������ ������������ �������
							el.css({
								position: 'absolute',
								zIndex: '-1',
								opacity: 0,
								margin: 0,
								padding: 0
							}).after(checkbox).prependTo(checkbox);

							checkbox.attr('unselectable', 'on').css({
								'-webkit-user-select': 'none',
								'-moz-user-select': 'none',
								'-ms-user-select': 'none',
								'-o-user-select': 'none',
								'user-select': 'none',
								display: 'inline-block',
								position: 'relative',
								overflow: 'hidden'
							});

							if (el.is(':checked')) checkbox.addClass('checked');
							if (el.is(':disabled')) checkbox.addClass('disabled');

							// ���� �� �������������
							checkbox.click(function() {
								if (!checkbox.is('.disabled')) {
									if (el.is(':checked')) {
										el.prop('checked', false);
										checkbox.removeClass('checked');
									} else {
										el.prop('checked', true);
										checkbox.addClass('checked');
									}
									el.change();
									return false;
								} else {
									return false;
								}
							});
							// ���� �� label
							el.closest('label').add('label[for="' + el.attr('id') + '"]').click(function(e) {
								checkbox.click();
								e.preventDefault();
							});
							// ������������ �� Space ��� Enter
							el.change(function() {
								if (el.is(':checked')) checkbox.addClass('checked');
								else checkbox.removeClass('checked');
							})
							// ����� ������������ �������, ������� ��������� � ���� label
							.keydown(function(e) {
								if (e.which == 13 || e.which == 32) checkbox.click();
							})
							.focus(function() {
								if (!checkbox.is('.disabled')) checkbox.addClass('focused');
							})
							.blur(function() {
								checkbox.removeClass('focused');
							})

						} // end checkbox()

						checkbox();

						// ���������� ��� ������������ ���������
						el.on('refresh', function() {
							el.parent().before(el).remove();
							checkbox();
						});

					}
				});
			// end checkbox

			// radio
			} else if (el.is(':radio')) {
				el.each(function() {
					if (el.parent('div.jq-radio').length < 1) {

						function radio() {

							var att = new attributes();
							var radio = $('<div' + att.id + ' class="jq-radio' + att.classes + '"' + att.title + '><div class="jq-radio__div"></div></div>');

							// ������ ������������ �����������
							el.css({
								position: 'absolute',
								zIndex: '-1',
								opacity: 0,
								margin: 0,
								padding: 0
							}).after(radio).prependTo(radio);

							radio.attr('unselectable', 'on').css({
								'-webkit-user-select': 'none',
								'-moz-user-select': 'none',
								'-ms-user-select': 'none',
								'-o-user-select': 'none',
								'user-select': 'none',
								display: 'inline-block',
								position: 'relative'
							});

							if (el.is(':checked')) radio.addClass('checked');
							if (el.is(':disabled')) radio.addClass('disabled');

							// ���� �� �����������������
							radio.click(function() {
								if (!radio.is('.disabled')) {
									radio.closest(opt.wrapper).find('input[name="' + el.attr('name') + '"]').prop('checked', false).parent().removeClass('checked');
									el.prop('checked', true).parent().addClass('checked');
									el.change();
									return false;
								} else {
									return false;
								}
							});
							// ���� �� label
							el.closest('label').add('label[for="' + el.attr('id') + '"]').click(function(e) {
								radio.click();
								e.preventDefault();
							});
							// ������������ ���������
							el.change(function() {
								el.parent().addClass('checked');
							})
							.focus(function() {
								if (!radio.is('.disabled')) radio.addClass('focused');
							})
							.blur(function() {
								radio.removeClass('focused');
							})

						} // end radio()

						radio();

						// ���������� ��� ������������ ���������
						el.on('refresh', function() {
							el.parent().before(el).remove();
							radio();
						});

					}
				});
			// end radio

			// file
			} else if (el.is(':file')) {
				// ������ ������������ ����
				el.css({
					position: 'absolute',
					top: 0,
					right: 0,
					width: '100%',
					height: '100%',
					opacity: 0,
					margin: 0,
					padding: 0
				}).each(function() {
					if (el.parent('div.jq-file').length < 1) {

						function file() {

							var att = new attributes();
							var file = $('<div' + att.id + ' class="jq-file' + att.classes + '"' + att.title + ' style="display: inline-block; position: relative; overflow: hidden"></div>');
							var name = $('<div class="jq-file__name">' + opt.filePlaceholder + '</div>').appendTo(file);
							var browse = $('<div class="jq-file__browse">' + opt.fileBrowse + '</div>').appendTo(file);
							el.after(file);
							file.append(el);
							if (el.is(':disabled')) file.addClass('disabled');
							el.change(function() {
								name.text(el.val().replace(/.+[\\\/]/, ''));
								if (el.val() == '') name.text(opt.filePlaceholder);
							})
							.focus(function() {
								file.addClass('focused');
							})
							.blur(function() {
								file.removeClass('focused');
							})
							.click(function() {
								file.removeClass('focused');
							})

						} // end file()

						file();

						// ���������� ��� ������������ ���������
						el.on('refresh', function() {
							el.parent().before(el).remove();
							file();
						})

					}
				});
			// end file

			// select
			} else if (el.is('select')) {
				el.each(function() {
					if (el.parent('div.jqselect').length < 1) {

						function selectbox() {

							// ��������� ��������� �������� ��� ��������� �������
							function preventScrolling(selector) {
								selector.unbind('mousewheel DOMMouseScroll').bind('mousewheel DOMMouseScroll', function(e) {
									var scrollTo = null;
									if (e.type == 'mousewheel') { scrollTo = (e.originalEvent.wheelDelta * -1); }
									else if (e.type == 'DOMMouseScroll') { scrollTo = 40 * e.originalEvent.detail; }
									if (scrollTo) {
										e.stopPropagation();
										e.preventDefault();
										$(this).scrollTop(scrollTo + $(this).scrollTop());
									}
								});
							}

							var option = $('option', el);
							var list = '';
							// ��������� ������ �������
							function makeList() {
								for (i = 0, len = option.length; i < len; i++) {
									var li = '',
											liClass = '',
											dataList = '',
											optionClass = '',
											optgroupClass = '',
											dataJqfsClass = '';
									var disabled = 'disabled';
									var selDis = 'selected sel disabled';
									if (option.eq(i).prop('selected')) liClass = 'selected sel';
									if (option.eq(i).is(':disabled')) liClass = disabled;
									if (option.eq(i).is(':selected:disabled')) liClass = selDis;
									if (option.eq(i).attr('class') !== undefined) {
										optionClass = ' ' + option.eq(i).attr('class');
										dataJqfsClass = ' data-jqfs-class="' + option.eq(i).attr('class') + '"';
									}

									var data = option.eq(i).data();
									for (var k in data) {
										if (data[k] != '') dataList += ' data-' + k + '="' + data[k] + '"';
									}

									li = '<li' + dataJqfsClass + dataList + ' class="' + liClass + optionClass + '">'+ option.eq(i).text() +'</li>';

									// ���� ���� optgroup
									if (option.eq(i).parent().is('optgroup')) {
										if (option.eq(i).parent().attr('class') !== undefined) optgroupClass = ' ' + option.eq(i).parent().attr('class');
										li = '<li' + dataJqfsClass + ' class="' + liClass + optionClass + ' option' + optgroupClass + '">'+ option.eq(i).text() +'</li>';
										if (option.eq(i).is(':first-child')) {
											li = '<li class="optgroup' + optgroupClass + '">' + option.eq(i).parent().attr('label') + '</li>' + li;
										}
									}

									list += li;
								}
							} // end makeList()

							// ��������� ������
							function doSelect() {
								var att = new attributes();
								var selectbox =
									$('<div' + att.id + ' class="jq-selectbox jqselect' + att.classes + '" style="display: inline-block; position: relative; z-index:' + opt.singleSelectzIndex + '">' +
											'<div class="jq-selectbox__select"' + att.title + ' style="position: relative">' +
												'<div class="jq-selectbox__select-text"></div>' +
												'<div class="jq-selectbox__trigger"><div class="jq-selectbox__trigger-arrow"></div></div>' +
											'</div>' +
										'</div>');

								el.css({margin: 0, padding: 0}).after(selectbox).prependTo(selectbox);

								var divSelect = $('div.jq-selectbox__select', selectbox);
								var divText = $('div.jq-selectbox__select-text', selectbox);
								var optionSelected = option.filter(':selected');

								// ����� ����� �� ���������
								if (optionSelected.length) {
									divText.text(optionSelected.text());
								} else {
									divText.text(option.first().text());
								}

								makeList();
								var searchHTML = '';
								if (opt.selectSearch) searchHTML =
									'<div class="jq-selectbox__search"><input type="search" autocomplete="off" placeholder="' + opt.selectSearchPlaceholder + '"></div>' +
									'<div class="jq-selectbox__not-found">' + opt.selectSearchNotFound + '</div>';
								var dropdown =
									$('<div class="jq-selectbox__dropdown" style="position: absolute">' +
											searchHTML +
											'<ul style="position: relative; list-style: none; overflow: auto; overflow-x: hidden">' + list + '</ul>' +
										'</div>');
								selectbox.append(dropdown);
								var ul = $('ul', dropdown);
								var li = $('li', dropdown);
								var search = $('input', dropdown);
								var notFound = $('div.jq-selectbox__not-found', dropdown).hide();
								if (li.length < opt.selectSearchLimit) search.parent().hide();

								// ���������� ����� ������� ����� �������
								var liWidth1 = 0,
										liWidth2 = 0;
								li.each(function() {
									var l = $(this);
									l.css({'display': 'inline-block', 'white-space': 'nowrap'});
									if (l.width() > liWidth1) {
										liWidth1 = l.innerWidth();
										liWidth2 = l.width();
									}
									l.css({'display': 'block'});
								});

								// ������������ ������ ������������� � ����������� ������
								// � ����������� �� ������ �������� ������
								var selClone = selectbox.clone().appendTo('body').width('auto');
								var selCloneWidth = selClone.width();
								selClone.remove();
								if (selCloneWidth == selectbox.width()) {
									divText.width(liWidth2);
									liWidth1 += selectbox.find('div.jq-selectbox__trigger').width();
								}
								if ( liWidth1 > selectbox.width() ) {
									dropdown.width(liWidth1);
								}

								// ������ ������������ ������
								el.css({
									position: 'absolute',
									left: 0,
									top: 0,
									width: '100%',
									height: '100%',
									opacity: 0
								});

								var selectHeight = selectbox.outerHeight();
								var searchHeight = search.outerHeight();
								var isMaxHeight = ul.css('max-height');
								var liSelected = li.filter('.selected');
								if (liSelected.length < 1) li.first().addClass('selected sel');
								if (li.data('li-height') === undefined) li.data('li-height', li.outerHeight());
								var position = dropdown.css('top');
								if (dropdown.css('left') == 'auto') dropdown.css({left: 0});
								if (dropdown.css('top') == 'auto') dropdown.css({top: selectHeight});
								dropdown.hide();

								// ���� ������ �� ��������� �����
								if (liSelected.length) {
									// ��������� �����, ������������ ��������� �������
									if (option.first().text() != optionSelected.text()) {
										selectbox.addClass('changed');
									}
									// �������� ������� ����� ���������� ������
									selectbox.data('jqfs-class', liSelected.data('jqfs-class'));
									selectbox.addClass(liSelected.data('jqfs-class'));
								}

								// ���� ������ ����������
								if (el.is(':disabled')) {
									selectbox.addClass('disabled');
									return false;
								}

								// ��� ����� �� �������������
								divSelect.click(function() {
									el.focus();

									// ���� iOS, �� �� ���������� ���������� ������
									var iOS = navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? true : false;
									if (iOS) return;

									// ����� ����������������
									if (opt.selectSmartPositioning) {
										var win = $(window);
										var topOffset = selectbox.offset().top;
										var bottomOffset = win.height() - selectHeight - (topOffset - win.scrollTop());
										var visible = opt.selectVisibleOptions;
										var liHeight = li.data('li-height');
										var	minHeight = liHeight * 5;
										var	newHeight = liHeight * visible;
										if (visible > 0 && visible < 6) minHeight = newHeight;
										if (visible == 0) newHeight = 'auto';

										// ��������� ����
										if (bottomOffset > (minHeight + searchHeight + 20))	{
											dropdown.height('auto').css({bottom: 'auto', top: position});
											function maxHeightBottom() {
												ul.css('max-height', Math.floor((bottomOffset - 20 - searchHeight) / liHeight) * liHeight);
											}
											maxHeightBottom();
											ul.css('max-height', newHeight);
											if (isMaxHeight != 'none') {
												ul.css('max-height', isMaxHeight);
											}
											if (bottomOffset < (dropdown.outerHeight() + 20)) {
												maxHeightBottom();
											}

										// ��������� �����
										} else {
											dropdown.height('auto').css({top: 'auto', bottom: position});
											function maxHeightTop() {
												ul.css('max-height', Math.floor((topOffset - win.scrollTop() - 20 - searchHeight) / liHeight) * liHeight);
											}
											maxHeightTop();
											ul.css('max-height', newHeight);
											if (isMaxHeight != 'none') {
												ul.css('max-height', isMaxHeight);
											}
											if ((topOffset - win.scrollTop() - 20) < (dropdown.outerHeight() + 20)) {
												maxHeightTop();
											}
										}
									}

									$('div.jqselect').css({zIndex: (opt.singleSelectzIndex - 1)}).removeClass('opened focused');
									selectbox.css({zIndex: opt.singleSelectzIndex});
									if (dropdown.is(':hidden')) {
										$('div.jq-selectbox__dropdown:visible').hide();
										dropdown.show();
										selectbox.addClass('opened');
									} else {
										dropdown.hide();
										selectbox.removeClass('opened');
									}

									// ������������ �� ���������� ������ ��� �������� ������
									if (li.filter('.selected').length) {
										// ���� �������� ���������� ������� �������,
										// �� ������ ������ ����� ������� ��� ������������ �������
										if ( (ul.innerHeight() / liHeight) % 2 != 0 ) liHeight = liHeight / 2;
										ul.scrollTop(ul.scrollTop() + li.filter('.selected').position().top - ul.innerHeight() / 2 + liHeight);
									}

									// ��������� ����
									if (search.length) {
										search.val('').keyup();
										notFound.hide();
										search.focus().keyup(function() {
											var query = $(this).val();
											li.each(function() {
												if (!$(this).html().match(new RegExp('.*?' + query + '.*?', 'i'))) {
													$(this).hide();
												} else {
													$(this).show();
												}
											});
											if (li.filter(':visible').length < 1) {
												notFound.show();
											} else {
												notFound.hide();
											}
										});
									}

									preventScrolling(ul);
									return false;
								});

								// ��� ��������� ������� �� ����� ������
								li.hover(function() {
									$(this).siblings().removeClass('selected');
								});
								var selectedText = li.filter('.selected').text();
								var selText = li.filter('.selected').text();

								// ��� ����� �� ����� ������
								li.filter(':not(.disabled):not(.optgroup)').click(function() {
									var t = $(this);
									var liText = t.text();
									if (selectedText != liText) {
										var index = t.index();
										if (t.is('.option')) index -= t.prevAll('.optgroup').length;
										t.addClass('selected sel').siblings().removeClass('selected sel');
										option.prop('selected', false).eq(index).prop('selected', true);
										selectedText = liText;
										divText.text(liText);

										// ��������� �����, ������������ ��������� �������
										if (option.first().text() != liText) {
											selectbox.addClass('changed');
										} else {
											selectbox.removeClass('changed');
										}

										// �������� ������� ����� ���������� ������
										if (selectbox.data('jqfs-class')) selectbox.removeClass(selectbox.data('jqfs-class'));
										selectbox.data('jqfs-class', t.data('jqfs-class'));
										selectbox.addClass(t.data('jqfs-class'));

										el.change();
									}
									if (search.length) {
										search.val('').keyup();
										notFound.hide();
									}
									dropdown.hide();
									selectbox.removeClass('opened');
								});
								dropdown.mouseout(function() {
									$('li.sel', dropdown).addClass('selected');
								});

								// ��������� �������
								el.change(function() {
									divText.text(option.filter(':selected').text());
									li.removeClass('selected sel').not('.optgroup').eq(el[0].selectedIndex).addClass('selected sel');
								})
								.focus(function() {
									selectbox.addClass('focused');
								})
								.blur(function() {
									selectbox.removeClass('focused');
								})
								// ��������� ������ � ����������
								.bind('keydown keyup', function(e) {
									divText.text(option.filter(':selected').text());
									li.removeClass('selected sel').not('.optgroup').eq(el[0].selectedIndex).addClass('selected sel');
									// �����, �����, PageUp
									if (e.which == 38 || e.which == 37 || e.which == 33) {
										dropdown.scrollTop(dropdown.scrollTop() + li.filter('.selected').position().top);
									}
									// ����, ������, PageDown
									if (e.which == 40 || e.which == 39 || e.which == 34) {
										dropdown.scrollTop(dropdown.scrollTop() + li.filter('.selected').position().top - dropdown.innerHeight() + liHeight);
									}
									if (e.which == 13) {
										dropdown.hide();
									}
								});

								// ������ ���������� ������ ��� ����� �� ��������� �������
								$(document).on('click', function(e) {
									// e.target.nodeName != 'OPTION' - ��������� ��� ������ ���� � �����
									// (��� ��������� ������� � ���������� ����������� ������� onclick)
									if (!$(e.target).parents().hasClass('jq-selectbox') && e.target.nodeName != 'OPTION') {
										if (search.length) search.val('').keyup();
										dropdown.hide().find('li.sel').addClass('selected');
										selectbox.removeClass('focused opened');
									}
								});

							} // end doSelect()

							// ������������
							function doMultipleSelect() {
								var att = new attributes();
								var selectbox = $('<div' + att.id + ' class="jq-select-multiple jqselect' + att.classes + '"' + att.title + ' style="display: inline-block; position: relative"></div>');

								el.css({margin: 0, padding: 0}).after(selectbox);

								makeList();
								selectbox.append('<ul>' + list + '</ul>');
								var ul = $('ul', selectbox).css({
									'position': 'relative',
									'overflow-x': 'hidden',
									'-webkit-overflow-scrolling': 'touch'
								});
								var li = $('li', selectbox).attr('unselectable', 'on').css({'-webkit-user-select': 'none', '-moz-user-select': 'none', '-ms-user-select': 'none', '-o-user-select': 'none', 'user-select': 'none', 'white-space': 'nowrap'});
								var size = el.attr('size');
								var ulHeight = ul.outerHeight();
								var liHeight = li.outerHeight();
								if (size !== undefined && size > 0) {
									ul.css({'height': liHeight * size});
								} else {
									ul.css({'height': liHeight * 4});
								}
								if (ulHeight > selectbox.height()) {
									ul.css('overflowY', 'scroll');
									preventScrolling(ul);
									// ������������ �� ���������� ������
									if (li.filter('.selected').length) {
										ul.scrollTop(ul.scrollTop() + li.filter('.selected').position().top);
									}
								}

								// ������ ������������ ������
								el.prependTo(selectbox).css({
									position: 'absolute',
									left: 0,
									top: 0,
									width: '100%',
									height: '100%',
									opacity: 0
								});

								// ���� ������ ����������
								if (el.is(':disabled')) {
									selectbox.addClass('disabled');
									option.each(function() {
										if ($(this).is(':selected')) li.eq($(this).index()).addClass('selected');
									});

								// ���� ������ ��������
								} else {

									// ��� ����� �� ����� ������
									li.filter(':not(.disabled):not(.optgroup)').click(function(e) {
										el.focus();
										selectbox.removeClass('focused');
										var clkd = $(this);
										if(!e.ctrlKey && !e.metaKey) clkd.addClass('selected');
										if(!e.shiftKey) clkd.addClass('first');
										if(!e.ctrlKey && !e.metaKey && !e.shiftKey) clkd.siblings().removeClass('selected first');

										// ��������� ������� ��� ������� Ctrl
										if(e.ctrlKey || e.metaKey) {
											if (clkd.is('.selected')) clkd.removeClass('selected first');
												else clkd.addClass('selected first');
											clkd.siblings().removeClass('first');
										}

										// ��������� ������� ��� ������� Shift
										if(e.shiftKey) {
											var prev = false,
													next = false;
											clkd.siblings().removeClass('selected').siblings('.first').addClass('selected');
											clkd.prevAll().each(function() {
												if ($(this).is('.first')) prev = true;
											});
											clkd.nextAll().each(function() {
												if ($(this).is('.first')) next = true;
											});
											if (prev) {
												clkd.prevAll().each(function() {
													if ($(this).is('.selected')) return false;
														else $(this).not('.disabled, .optgroup').addClass('selected');
												});
											}
											if (next) {
												clkd.nextAll().each(function() {
													if ($(this).is('.selected')) return false;
														else $(this).not('.disabled, .optgroup').addClass('selected');
												});
											}
											if (li.filter('.selected').length == 1) clkd.addClass('first');
										}

										// �������� ��������� �����
										option.prop('selected', false);
										li.filter('.selected').each(function() {
											var t = $(this);
											var index = t.index();
											if (t.is('.option')) index -= t.prevAll('.optgroup').length;
											option.eq(index).prop('selected', true);
										});
										el.change();

									});

									// �������� ��������� � ����������
									option.each(function(i) {
										$(this).data('optionIndex', i);
									});
									el.change(function() {
										li.removeClass('selected');
										var arrIndexes = [];
										option.filter(':selected').each(function() {
											arrIndexes.push($(this).data('optionIndex'));
										});
										li.not('.optgroup').filter(function(i) {
											return $.inArray(i, arrIndexes) > -1;
										}).addClass('selected');
									})
									.focus(function() {
										selectbox.addClass('focused');
									})
									.blur(function() {
										selectbox.removeClass('focused');
									});

									// ������������ � ����������
									if (ulHeight > selectbox.height()) {
										el.keydown(function(e) {
											// �����, �����, PageUp
											if (e.which == 38 || e.which == 37 || e.which == 33) {
												ul.scrollTop(ul.scrollTop() + li.filter('.selected').position().top - liHeight);
											}
											// ����, ������, PageDown
											if (e.which == 40 || e.which == 39 || e.which == 34) {
												ul.scrollTop(ul.scrollTop() + li.filter('.selected:last').position().top - ul.innerHeight() + liHeight * 2);
											}
										});
									}

								}
							} // end doMultipleSelect()
							if (el.is('[multiple]')) doMultipleSelect(); else doSelect();
						} // end selectbox()

						selectbox();

						// ���������� ��� ������������ ���������
						el.on('refresh', function() {
							el.parent().before(el).remove();
							selectbox();
						});

					}
				});
			// end select

			// reset
			} else if (el.is(':reset')) {
				el.click(function() {
					setTimeout(function() {
						el.closest(opt.wrapper).find('input, select').trigger('refresh');
					}, 1)
				});
			}
			// end reset

		});

	}
})(jQuery);