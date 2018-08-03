LeadGen.PostEdit = LeadGen.PostEdit || {};
LeadGen.PostEdit.init = function () {

    if (LeadGen.PostEdit.isFirstInit === undefined) {
        LeadGen.PostEdit.isFirstInit = true;
    } else {
        LeadGen.PostEdit.isFirstInit = false;
    }

    // Process File Upload
    var uploadForm = document.getElementById('uploader');
    uploadForm.onsubmit = function () {
        $('#AttachmentsUploadPopUp').modal('hide');
        $('#LoadingWindowSplash').show();

        var formdata = new FormData(); //FormData object
        var filesToUpload = document.getElementById('filesToUpload');
        //Iterating through each files selected in filesToUpload
        for (i = 0; i < filesToUpload.files.length; i++) {
            //Appending each file to FormData object
            formdata.append(filesToUpload.files[i].name, filesToUpload.files[i]);
        }
        //Creating an XMLHttpRequest and sending
        var xhr = new XMLHttpRequest();
        xhr.open('POST', uploadForm.getAttribute("action"));
        xhr.send(formdata);
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                $('#LoadingWindowSplash').hide();
                $('#attachaments').html(xhr.responseText);
            }
        }
        return false; //Prevent Real Form Submition
    }

    //EnableAttachamentDeletion
    $("#attachaments").on("click", ".attachment-delete", function () {

        var attachment = $(this).closest('[data-attachmentID]');

        var attachmentID = attachment.attr('data-attachmentID');
        var subjectID = attachment.attr('data-subjectID');
        var unlinkURL = attachment.attr('data-unlinkURL');

        bootbox.dialog({
            message: "Are you sure you want to delete the Attachment?",
            title: "Attachment Removal Confirmation",
            closeButton: true,
            buttons: {
                close: {
                    label: "Cancel",
                    className: "btn-default"
                },
                confirm: {
                    label: "Delete!",
                    className: "btn-danger",
                    callback: function () {

                        $.post(unlinkURL, { subjectID: subjectID, attachmentID: attachmentID }, function (data, status) {
                            if (status == 'success') {

                                attachment.css("background-color", "#FF3700");
                                attachment.fadeOut(400, function () {
                                    attachment.remove();
                                });
                            }
                            else {
                                bootbox.alert(data.message);
                            }
                        });
                    }
                }
            }
        });
    });



    //TinyMCE

    var pageWidth = 600;
    //https://habrahabr.ru/post/266337/
    resizeImage = function ($image, width, height) {

        var originalWidth = parseInt($image.data('originalWidth'), 10),
            originalHeight = parseInt($image.data('originalHeight'), 10),
            ratio,
            defaultWidth,
            defaultHeight,
            //link = $image.attr('src'),
            link = $image[0].src,
            linkParams;

        if (typeof width === 'undefined' || width === null) {
            //width = parseInt($image.attr('width'), 10);
            width = parseInt($image[0].width, 10);
        }

        if (typeof height === 'undefined' || height === null) {
            //height = parseInt($image.attr('height'), 10);
            height = parseInt($image[0].height, 10);
        }

        defaultWidth = width;
        defaultHeight = height;

        /* Для старых изображений, без сохраненных оригинальных размеров */
        if (isNaN(originalWidth) || originalWidth === 0 || isNaN(originalHeight) || originalHeight === 0) {
            $image
                .attr({
                    width: '',
                    height: ''
                })
                .css({
                    maxWidth: 'none',
                    maxHeight: 'none'
                });

            originalWidth = $image.width();
            originalHeight = $image.height();

            ratio = originalWidth / originalHeight;

            var maxWidth = Math.min(originalWidth, pageWidth),
                maxHeight = (maxWidth === originalWidth ? originalHeight : Math.round(maxWidth / ratio));

            $image
                .attr({
                    width: width,
                    height: height,
                    'data-original-width': originalWidth,
                    'data-original-height': originalHeight
                })
                .css({
                    maxWidth: maxWidth,
                    maxHeight: maxHeight
                });
        } else {
            ratio = originalWidth / originalHeight;
        }

        width = Math.min(originalWidth, pageWidth, width);
        height = (width === originalWidth ? originalHeight : Math.round(width / ratio));



        if (link.substr(0, 7) === 'http://') {
            linkParams = link.substr(7).split('/');
        } else {
            linkParams = link.split('/');
        }

        /* Проверка соответсвия ссылки определенной структуре, и обновление ее */
        if (linkParams.length === 6 && linkParams[0] === window.location.host && (linkParams[1] === 'r' || linkParams[1] === 'c') &&
            isDecimal(linkParams[2]) && isDecimal(linkParams[3])) {
            link = 'http://' + linkParams[0] + '/' + linkParams[1] + '/' + width + '/' + height + '/' + linkParams[4] + '/' + linkParams[5];
            $image.attr({
                src: link,
                'data-mce-src': link
            });
        }



        if (width !== defaultWidth || height !== defaultHeight) {
            $image.attr({
                width: width,
                height: height
            });
        }
    }

    //Enable TinyMCE
    tinymce.remove("textarea.tinymce");
    tinymce.init({
        /* Конфигурация редактора */
        selector: "textarea.tinymce",
        plugins: [
            "advlist autolink lists link image charmap print preview anchor",
            "searchreplace visualblocks code fullscreen",
            "insertdatetime media table contextmenu paste pagebreak"
        ],
        toolbar: "insertfile undo redo | pagebreak | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
        pagebreak_separator: "<!--more-->",
        ///* https://habrahabr.ru/post/266337/ */
        //setup: function (editor) {
        //    editor.on('NodeChange', function (e) {
        //        if (e.element.nodeName === 'IMG' && e.element.classList.contains('mce-object') === false) {
        //            resizeImage($(e.element), e.width, e.height);
        //        }
        //    });
        //}
    });

    LeadGen.ui.tagit = {
        init: function (selector) {

            //Enable Tag Editor
            $(selector).tagit({
                minLength: 2,
                removeConfirmation: true,
                allowSpaces: true,
                afterTagRemoved: function (event, ui) {

                    var $tagitElement = $(event.target);
                    var termListHtmlNameStart = $tagitElement.attr("data-termListHtmlName") + "[";
                    var $tagsLeft = $tagitElement.find("li.tagit-choice");

                    var newIndex = 0;
                    $tagsLeft.each(function () {

                        var $tagInputs = $(this).find(":input[name^='" + termListHtmlNameStart.replace(/(:|\.|\[|\]|,)/g, "\\$1") + "']");
                        var tagIndex = $tagInputs.first().attr("name").replace(termListHtmlNameStart, "");
                        tagIndex = tagIndex.substring(0, tagIndex.indexOf("]"));

                        $tagInputs.each(function () {
                            var newName = $(this).attr("name").replace(termListHtmlNameStart + tagIndex + "]", termListHtmlNameStart + newIndex + "]");
                            $(this).attr("name", newName)
                        });

                        newIndex = newIndex + 1;
                    });

                },
                beforeTagAdded: function (event, ui) {
                    var tag = $(ui.tag).find("span.tagit-label").text();
                    try {
                        //If tag parses as JSON, means it is existing tag, do not create new tag, do not do anything
                        var json = JSON.parse(tag);
                    }
                    catch (e) {
                        //Tag is not a JSON, means it is a new tag (name), create new tag

                        $tagitElement = $(event.target);

                        var tagCreateUrl = $tagitElement.attr("data-tagCreateUrl");
                        var taxonomyID = $tagitElement.attr("data-taxonomyID");

                        $.ajax({
                            url: tagCreateUrl,
                            method: "POST",
                            data: {
                                taxonomyID: taxonomyID,
                                tagName: tag
                            },
                            dataType: "json",
                            success: function (data) {
                                $tagitElement.tagit("createTag", JSON.stringify(data));
                            }
                        });

                        //Clear entered tag
                        $(event.target).find("li.tagit-new input:text").val('');
                        //Prevent default tag creation
                        return false;
                    }
                },
                afterTagAdded: function (event, ui) {
                    var item = JSON.parse($(ui.tag).find("span.tagit-label").text());
                    item.level = item.level || 1;

                    var indexInList = $(event.target).find("li.tagit-choice").length - 1;
                    var termHtmlName = $(event.target).attr("data-termListHtmlName") + "[" + indexInList + "]";

                    var inputChecked = '<input type="hidden" name="' + termHtmlName + '.isChecked" value="true" />';
                    var inputID = '<input type="hidden" name="' + termHtmlName + '.id" value="' + item.id + '" />';
                    var inputName = '<input type="hidden" name="' + termHtmlName + '.level" value="' + item.level + '" />';
                    var inputUrl = '<input type="hidden" name="' + termHtmlName + '.name" value="' + item.name + '" />';
                    var inputTermURL = '<input type="hidden" name="' + termHtmlName + '.termURL" value="' + item.termURL + '" />';

                    $(ui.tag).find("span.tagit-label").text(item.name);
                    $(ui.tag).find('input').remove();
                    $(ui.tag).append(inputChecked).append(inputID).append(inputName).append(inputUrl).append(inputTermURL);
                },
                tagSource: function (request, response) {
                    $.ajax({
                        url: $(this.element).attr("data-tagSourceUrl"),
                        data: {
                            taxonomyID: $(this.element).attr("data-taxonomyID"),
                            termSearch: request.term
                        },
                        dataType: "json",
                        success: function (data) {
                            response($.map(data, function (item) {
                                return {
                                    label: item.name,
                                    value: JSON.stringify(item)
                                }
                            }));
                        }
                    });
                }
            });

        }
    };

    LeadGen.ui.tagit.init(".TagItEditor");

    // Enable Case Insensitive Contains 
    (function () {
        // NEW selector
        jQuery.expr[':'].Contains = function (a, i, m) {
            return jQuery(a).text().toUpperCase()
                .indexOf(m[3].toUpperCase()) >= 0;
        };

        // OVERWRITES old selecor
        jQuery.expr[':'].contains = function (a, i, m) {
            return jQuery(a).text().toUpperCase()
                .indexOf(m[3].toUpperCase()) >= 0;
        };
    })();

    //Search selected terms
    $('.panel.taxonomyEditor input[type=search]').keyup(function () {

        var $search = $(this);
        var $termsBlock = $search.closest(".taxonomyEditor").find(".terms");

        $termsBlock.find("label").css("text-decoration", "none");

        var text = $search.val();
        if (text == "") {
            return;
        }

        var $foundTerms = $termsBlock.find("label:contains('" + text + "')");

        if ($foundTerms.length == 0) {
            alert("Not found");
            return;
        }

        $foundTerms.css("text-decoration", "underline");
        var $foundTerm = $foundTerms.first()


        var scrollpx = $foundTerm.offset().top - $termsBlock.offset().top + $($termsBlock).scrollTop();

        $termsBlock.animate({
            scrollTop: scrollpx
        }, 1000);

    });


    //Show selected terms
    $('.panel.taxonomyEditor .terms').each(function () {
        $(this).find('input:checked').each(function () {
            var $div = $(this).closest("div");
            var name = $div.find("label").text();
            $div.closest('.taxonomyEditor').find(".terms-selected").append(name + ", ");
        });
    });


    $("#postParentUrl").autocomplete({
        source: function (request, response) {
            $.ajax({
                url: LeadGen.PostEdit.SearchPostsJsonUrl,
                dataType: "json",
                data: {
                    typeID: LeadGen.PostEdit.PostTypeID,
                    statusID: "",
                    query: request.term
                },
                success: function (data) {
                    items = jQuery.map(data, function (post, i) {
                        return { id: post.id, value: post.postURLHierarchical };
                    });
                    response(items);
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            $("#postParentID").val(ui.item ? ui.item.id : "");
        },
        open: function () {
            $(this).removeClass("ui-corner-all").addClass("ui-corner-top");
        },
        close: function () {
            $(this).removeClass("ui-corner-top").addClass("ui-corner-all");
        },
        change: function (event, ui) {
            if ($('#postParentUrl').val() == "") {
                $("#postParentID").val("");
            }
        }
    });

    var errorText = $(".validation-summary-errors").html();
    if (errorText) {
        LeadGen.ui.showNotificationLabel(errorText, 'danger');
    } else if (LeadGen.PostEdit.isFirstInit == false) {
        LeadGen.ui.showNotificationLabel();
    }
    
};