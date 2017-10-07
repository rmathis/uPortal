<%--
    Licensed to Apereo under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Apereo licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License.  You may obtain a
    copy of the License at the following location:
      http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
--%>
<%@ include file="/WEB-INF/jsp/include.jsp"%>

<template id="search-results-tab-header-template">
    <li role="presentation" class="up-search-tab"><a href="" data-toggle="tab"></a></li>
</template>

<template id="search-results-tab-panel-template">
    <div class="up-search-panel tab-pane">
        <ul class="up-search-list list-group"></ul>
    </div>
</template>

<template id="search-result-item-template">
    <li class="up-search-list-item list-group-item">
        <span class="up-search-list-item-secondary-content pull-right">
            <a class="up-search-list-item-secondary-action" href="#">
                <i class="fa fa-window-maximize" aria-hidden="true"></i>
            </a>
        </span>
        <span class="up-search-list-item-primary-content">
            <i class="up-search-list-item-avatar pull-left fa"></i>
            <h3 class="up-search-list-item-title list-group-item-heading"></h3>
            <span class="up-search-list-item-body list-group-item-text">
                <dl></dl>
            </span>
        </span>
    </li>
</template>

<template id="search-result-item-detail-template">
    <dt></dt>
    <dd></dd>
</template>

<template id="search-result-no-results-template">
    <div class="h3 text-center">
         <i class="fa fa-exclamation-triangle" aria-hidden="true"></i>
         No Results Found
         <i class="fa fa-exclamation-triangle" aria-hidden="true"></i>
     </div>
</template>

<script src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js"></script>
<!-- Does the above replace underscore? -->
<script src="https://rawgit.com/github/fetch/v2.0.3/fetch.js"></script>
<script src="https://rawgit.com/webcomponents/template/v1.0.0/template.js"></script>
<script src="https://rawgit.com/taylorhakes/promise-polyfill/6.0.2/promise.js"></script>
<!-- WTF are the three above? -->
<style>
    #search-results-tab-header {
        display: inline-block;
    }

    .up-search-list {
        margin: 0 6rem;
    }

    .up-search-list .up-search-list-item .up-search-list-item-avatar {
        margin-left: 2rem;
        font-size: 4rem;
    }

    .up-search-list .up-search-list-item .up-search-list-item-title {
        font-weight: bold;
    }

    .up-search-list .up-search-list-item .up-search-list-item-title,
    .up-search-list .up-search-list-item .up-search-list-item-body dl {
        margin-left: 8rem;
        margin-bottom: .5rem;
    }

    #search-results-tab-panel dt,
    #search-results-tab-panel dd {
        display: inline;
    }

    #search-results-tab-panel dt {
        font-weight: bold;
    }

    #search-results-tab-panel dt::before {
        content: '';
        display: block;
    }

    .up-search-list .up-search-list-item .up-search-list-item-secondary-content {
        margin-right: 2rem;
    }

    .up-search-list .up-search-list-item .up-search-list-item-secondary-action i {
        font-size: 2rem;
    }
</style>
<div id="search-results-tab-panel" class="">
    <div class="text-center">
        <ul id="search-results-tab-header" class="nav nav-pills"></ul>
    </div>
    <div id="search-results-tab-content" class="tab-content clearfix"></div>
</div>

<script language="javascript" type="text/javascript">
// search results metadata
// TODO: This solution doesn't honor local configuration or internationalization
var metadata = { "people" : { "avatar" : "fa-user-circle", "attributes" : [ "displayName", "title", "department", "telephone", "mail" ] },
                 "portlets" : { "avatar" : "fa-th", "attributes" : [ "title", "description" ] } };
// fetch search results
<c:url value="/api/v5-0/portal/search" var="url">
    <c:param name="q" value="${param.query}" />
</c:url>
fetch('${url}', {credentials: 'same-origin'})
    // check for HTTP 2XX Okay response
    .then(function (response) {
        if (response.status >= 200 && response.status < 300) {
            return response;
        } else {
            var error = new Error(response.statusText);
            error.response = response;
            throw error;
        }
    })
    // extract json from response
    .then(function (response) {
        return response.json();
    })
    .then(function (response) {
        _.forEach(response, function (resultSet, tabProperty) {
            // Generate formatted text
            var tabName = _.startCase(tabProperty);
            var tabId = _.kebabCase(tabProperty);
            // Setup tab header template
            var tabTemplate = document.getElementById('search-results-tab-header-template');
            var tabHeader = document.importNode(tabTemplate.content, true);
            // Add content to tab header template
            var tabHeaderLink = tabHeader.querySelector('a');
            tabHeaderLink.textContent = tabName;
            tabHeaderLink.href = '#' + tabId;
            // Add tab header to page
            document.getElementById('search-results-tab-header').appendChild(tabHeader);

            // setup the tab panel template
            var tabPanelTemplate = document.getElementById('search-results-tab-panel-template');
            var tabPanel = document.importNode(tabPanelTemplate.content, true);
            tabPanel.querySelector('div').id = tabId;
            var tabPanelResultList = tabPanel.querySelector('ul');

            if (resultSet.length == 0) {
                var noResultsTemplate = document.getElementById('search-result-no-results-template');
                var noResults = document.importNode(noResultsTemplate.content, true);
                tabPanel.querySelector('div').appendChild(noResults);
            } else {
                // add each result from the result set to the panel
                _.forEach(resultSet, function (result) {
                    // setup search result item template
                    var searchResultTemplate = document.getElementById('search-result-item-template');
                    var searchResult = document.importNode(searchResultTemplate.content, true);
                    // add top level content
                    searchResult.querySelector('.up-search-list-item-avatar').classList.add(metadata[tabProperty].avatar);
                    searchResult.querySelector('.up-search-list-item-title').textContent = result[metadata[tabProperty].attributes[0]];
                    if (result.url) {
                        searchResult.querySelector('.up-search-list-item-secondary-action').href = result.url;
                    } else {
                        searchResult.querySelector('.up-search-list-item-secondary-content').style.visibility = 'hidden';
                    }
                    var resultAttributeList = searchResult.querySelector('dl');
                    // QUESTION: should that attribute picking be handled server-side? YES
                    // add each attribute that should be shown for a result
                    _.forEach(metadata[tabProperty].attributes, function (attributeName) {
                        var attributeValue = result[attributeName];
                        if (attributeValue) {
                            // setup attribute pairing template
                            var attributePairTemplate = document.getElementById('search-result-item-detail-template');
                            var attributePair = document.importNode(attributePairTemplate.content, true);
                            // add values
                            attributePair.querySelector('dt').textContent = _.startCase(attributeName);
                            attributePair.querySelector('dd').textContent = attributeValue;
                            // add attributes to the result
                            resultAttributeList.appendChild(attributePair);
                        }
                    });
                    // add result to panel
                    tabPanelResultList.appendChild(searchResult);
                });
            }
            // add the tab panel to the page
            document.getElementById('search-results-tab-content').appendChild(tabPanel);
        });

        // set first tab active
        var firstTab = document.querySelector('#search-results-tab-header .up-search-tab');
        if (firstTab) firstTab.classList.add('active');
        var firstPanel = document.querySelector('#search-results-tab-panel .up-search-panel');
        if (firstPanel) firstPanel.classList.add('active');
    })
    // log error to browser console
    .catch(function(error) {
        if (error.response.status == 404) {
            var tabPanel = document.getElementById('search-results-tab-panel');
            var noResultsTemplate = document.getElementById('search-result-no-results-template');
            var noResults = document.importNode(noResultsTemplate.content, true);
            tabPanel.appendChild(noResults);
        } else {
            console.log('request failed', error)
        }
    });
</script>
