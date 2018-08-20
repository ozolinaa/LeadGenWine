using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Primitives;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;

namespace LeadGen.Code.Sys
{
    public class CacheProvider
    {
        private static CancellationTokenSource _resetCacheToken = new CancellationTokenSource();
        private static MemoryCacheEntryOptions _options;
        private readonly IMemoryCache _cache;

        public CacheProvider(IMemoryCache memoryCache)
        {
            _cache = memoryCache;
            _options = new MemoryCacheEntryOptions();
            _options.SetPriority(CacheItemPriority.Normal);
            _options.SetSlidingExpiration(TimeSpan.FromHours(24));
            _options.AddExpirationToken(new CancellationChangeToken(_resetCacheToken.Token));
        }

        public void Set(string key, object value)
        {
            _cache.Set(key, value, _options);
        }

        public void Remove(string key)
        {
            _cache.Remove(key);
        }

        public void Reset()
        {
            if (_resetCacheToken != null && !_resetCacheToken.IsCancellationRequested && _resetCacheToken.Token.CanBeCanceled)
            {
                _resetCacheToken.Cancel();
                _resetCacheToken.Dispose();
            }

            _resetCacheToken = new CancellationTokenSource();
        }


        public bool TryGetValue<T>(string key, out T value)
        {
            return _cache.TryGetValue<T>(key, out value);
        }
    }
}
