function refreshList() {
    var query = $('#query').text();
    url = '/sampler/refresh?keyword=' + query;
    $.ajax({
        type: 'POST',
        url:  url,
        datatype: 'xml',
        success: function(responseText,status) {
            $('#videoCarousel div.item').remove();
            $('#selectorCarousel div.item').remove();
            var $videoInner = $('#videoCarousel > div.carousel-inner');
            var $selectorInner = $('#selectorCarousel > div.carousel-inner');
            var $xml = $(responseText);
            var $movie = $xml.find('movie');
            
            var selector_number = 0;
            var item_number = 0;
            var $selectorItem = null;
            var $selectorRow;
            jQuery.each($movie,function(total_number) {
                var $movie = $(this);
                var $videoItem;
                if (total_number == 0) {
                  $videoItem = $('<div>').attr({'class':'item active','name':total_number})
                  $videoInner.append($videoItem);
                } else {
                  $videoItem = $('<div>').attr({'class':'item','name':total_number})
                  $videoInner.append($videoItem);   
                }
                var url = "http://www.dmm.co.jp/litevideo/-/part/=/affi_id=quotto-003/cid=" + $movie.find('dmm_id').text() + "/size=560_360";
                $videoItem.append($('<object width="560" scrolling="no" height="380" frameborder="0" style="border:none;" border="0" type="text/html">').attr('data',url));
                $tagsDiv = $('<div class="tags"></div>');
                $videoItem.append($tagsDiv);
                $tags = $movie.find('tag')
                jQuery.each($tags,function() {
                    $tagsDiv.append('<a href="/sampler/search?keyword='+$(this).text()+'">'+$(this).text()+'</a>');
                })

                if(item_number == 0 ) {
                    if(selector_number == 0) {
                        $selectorItem = $('<div class="selector item active">');
                        $selectorRow = $('<div class="selector_row">');
                        $selectorItem.append($selectorRow);                        
                    } else {
                        $selectorItem = $('<div class="selector item">');
                        $selectorRow = $('<div class="selector_row">');
                        $selectorItem.append($selectorRow);
                    }
                }
                $selectorItemDiv = $('<div class="selector_item">').attr('name',total_number);
                $img = $('<img>').attr({
                    'alt':$movie.find('title').text(),
                    'src':$movie.find('thumbnail').text(),
                    'data-target':'#videoCarousel',
                    'data-slide-to':total_number,
                    'data-toggle':'tooltip',
                    'data-original-title':$movie.find('title').text(),
                    'rel':'thumbnail'
                });
                $selectorItemDiv.append($img);
                $selectorRow.append($selectorItemDiv);
                item_number += 1;
                if(item_number == 10) {
                    $selectorInner.append($selectorItem);
                    selector_number += 1;
                    item_number = 0;
                }
            });
            if(item_number > 0) {
                $selectorInner.append($selectorItem);
            }
            $('img[rel=thumbnail]').tooltip();
            $('img[rel=thumbnail]').tooltip();
            // 初期表示時は最初のサムネイルをマークアップする
            $('div.selector_item:first').css('background','rgba(255,0,0,0.7)');
        }
    });
}

function selectionQuery() {
    url = '/sampler/keyword_selection';
    $.ajax({
        type: 'GET',
        url: url,
        datatype: 'xml',
        success: function(responseText,status) {
            var $query_counts = $(responseText).find("query-count");
            $('#keywordModal div.modal-body').children().remove();
            jQuery.each($query_counts,function() {
                $query_count = $(this);
                var $queryLink = $('<a></a>');
                var query = $query_count.find('query').text();
                $queryLink.attr('href','/sampler/search?keyword='+query);
                $queryLink.text(query);
                $('#keywordModal div.modal-body').append($queryLink);
            });
        }
    })
}