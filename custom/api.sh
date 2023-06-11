#!/usr/bin/env bash

    github_page="1"
    github_per_page="100"
    github_workflows_results=()

    # Get the release list
    while true; do
        response=$(curl -s -L \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${REPO_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "https://api.github.com/repos/stupidloud/nanopi-openwrt/actions/runs?per_page=${github_per_page}&page=${github_page}")

        # Check if the response is empty or an error occurred
        if [ -z "${response}" ] || [[ "${response}" == *"Not Found"* ]]; then
            break
        fi

        # Append the current page's results to the overall results array
        github_workflows_results+=("${response}")

        # Check if the current page has fewer results than the per_page limit
        if [ "$(echo "${response}" | jq '. | length')" -lt "${github_per_page}" ]; then
            break
        fi

        ((github_page++))
    done

    # Sort the results by updated_at date in descending order
    all_workflows_list="josn_api_workflows"
    if [[ "${#github_workflows_results[*]}" -ne "0" ]]; then
        # Concatenate all the results into a single JSON array
        all_results=$(echo "${github_workflows_results[*]}" | jq -s 'add')

        # Sort the results
        echo "${all_results[*]}" |
            jq -c '.workflow_runs[] | select(.status != "in_progress") | {date: .updated_at, id: .id, name: .name}' \
                >${all_workflows_list}
        cp -Rf ${all_workflows_list} ${GITHUB_WORKSPACE}/Github_Api/xinapi
        [[ "${?}" -eq "0" && -s "${all_workflows_list}" ]] || error_msg "(2.1.1) The api.github.com for workflows query failed."
        echo -e "${INFO} (2.1.1) The api.github.com for workflows request successfully."
        [[ "${out_log}" == "true" ]] && echo -e "${INFO} (2.1.1) All workflows runs list:\n$(cat ${all_workflows_list})"
    else
        echo -e "${TIPS} (2.1.2) The workflows list is empty. skip."
    fi
