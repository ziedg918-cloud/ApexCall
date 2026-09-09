// Supabase client + common realtime helpers
(function () {
    const cfg = window.ACHIEVEMENT_WALL_CONFIG;
    if (!cfg || !cfg.SUPABASE_URL || !cfg.SUPABASE_PUBLISHABLE_KEY) {
        throw new Error('Supabase configuration is missing.');
    }

    window.awSupabase = window.supabase.createClient(
        cfg.SUPABASE_URL,
        cfg.SUPABASE_PUBLISHABLE_KEY,
        { auth: { persistSession: true, autoRefreshToken: true } }
    );

    window.awAuthReady = (async function () {
        const client = window.awSupabase;
        const { data: sessionData } = await client.auth.getSession();
        if (!sessionData.session) {
            const { error } = await client.auth.signInAnonymously();
            if (error) throw error;
        }
        await client.realtime.setAuth();
        return true;
    })();

    window.awChannel = null;

    window.awGetChannel = async function () {
        await window.awAuthReady;
        if (window.awChannel) return window.awChannel;
        const channel = window.awSupabase.channel(cfg.CHANNEL, {
            config: {
                private: true,
                broadcast: { ack: true }
            }
        });
        window.awChannel = channel;
        return channel;
    };

    window.awSubscribe = async function (eventHandlers, statusHandler) {
        const channel = await window.awGetChannel();
        for (const [event, handler] of Object.entries(eventHandlers || {})) {
            channel.on('broadcast', { event }, handler);
        }
        return new Promise((resolve, reject) => {
            channel.subscribe((status, err) => {
                if (typeof statusHandler === 'function') statusHandler(status, err);
                if (status === 'SUBSCRIBED') resolve(channel);
                if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') reject(err || new Error(status));
            });
        });
    };

    window.awBroadcast = async function (event, payload) {
        const channel = await window.awGetChannel();
        return channel.send({ type: 'broadcast', event, payload });
    };
})();
