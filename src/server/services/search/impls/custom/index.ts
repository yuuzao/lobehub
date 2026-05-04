import type { UniformSearchResponse } from '@lobechat/types';
import { TRPCError } from '@trpc/server';

import { toolsEnv } from '@/envs/tools';

import { type SearchServiceImpl } from '../type';

/**
 * Custom search implementation
 *
 * 通用自定义搜索引擎，支持任何返回 UniformSearchResponse 格式的 HTTP 搜索 API。
 * 通过环境变量 CUSTOM_SEARCH_URL 配置搜索端点。
 *
 * API 约定：
 *   GET {CUSTOM_SEARCH_URL}/search?q={query}
 *   响应格式须为 UniformSearchResponse
 */
export class CustomImpl implements SearchServiceImpl {
  async query(
    query: string,
    params?: {
      searchCategories?: string[];
      searchEngines?: string[];
      searchTimeRange?: string;
    },
  ): Promise<UniformSearchResponse> {
    const baseUrl = toolsEnv.CUSTOM_SEARCH_URL;

    if (!baseUrl) {
      throw new TRPCError({
        code: 'NOT_IMPLEMENTED',
        message: 'Custom search is not configured. Please set CUSTOM_SEARCH_URL.',
      });
    }

    const url = new URL('/search', baseUrl);
    url.searchParams.set('q', query);

    if (params?.searchCategories?.length) {
      url.searchParams.set('categories', params.searchCategories.join(','));
    }
    if (params?.searchEngines?.length) {
      url.searchParams.set('engines', params.searchEngines.join(','));
    }
    if (params?.searchTimeRange) {
      url.searchParams.set('time_range', params.searchTimeRange);
    }

    try {
      const response = await fetch(url.toString());

      if (!response.ok) {
        throw new Error(
          `Custom search API responded with ${response.status}: ${response.statusText}`,
        );
      }

      const data: UniformSearchResponse = await response.json();

      return data;
    } catch (e) {
      console.error('[CustomSearch]', e);

      throw new TRPCError({
        code: 'SERVICE_UNAVAILABLE',
        message: (e as Error).message,
      });
    }
  }
}
