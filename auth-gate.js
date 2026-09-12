/*
Shared admin login gate.

Include this file (after supabase-client.js) on any page that can WRITE
data or trigger celebrations: admin.html, dashboard.html, phone.html.

DO NOT include this on wall.html — the wall must stay open with no
login, since it's meant to run unattended on a display PC.

Every page still gets an anonymous Supabase session automatically
(from supabase-client.js), which is enough to READ data. This gate
additionally requires a REAL (non-anonymous) login before letting the
person interact with the page, and Row Level Security on the database
enforces the same rule server-side, so this is not just a client-side
lock.
*/
(function () {

    function injectStyles() {
        if (document.getElementById('awAuthGateStyles')) return;
        const style = document.createElement('style');
        style.id = 'awAuthGateStyles';
        style.textContent = `
            #awAuthGate {
                position: fixed;
                inset: 0;
                z-index: 999999;
                background: rgba(10, 10, 15, 0.97);
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: Arial, Helvetica, sans-serif;
            }
            #awAuthGate .aw-box {
                width: 320px;
                max-width: 90vw;
                background: #1c1c24;
                border: 1px solid #333;
                border-radius: 10px;
                padding: 28px;
                color: #fff;
                box-shadow: 0 10px 40px rgba(0,0,0,0.5);
            }
            #awAuthGate h2 {
                margin: 0 0 18px;
                font-size: 18px;
                text-align: center;
            }
            #awAuthGate input {
                width: 100%;
                padding: 10px 12px;
                margin-bottom: 12px;
                border-radius: 6px;
                border: 1px solid #444;
                background: #111;
                color: #fff;
                font-size: 14px;
                box-sizing: border-box;
            }
            #awAuthGate button {
                width: 100%;
                padding: 10px 12px;
                border-radius: 6px;
                border: none;
                background: #f4c430;
                color: #111;
                font-weight: 700;
                cursor: pointer;
                font-size: 14px;
            }
            #awAuthGate button:disabled {
                opacity: 0.6;
                cursor: default;
            }
            #awAuthGate .aw-error {
                color: #ff6b6b;
                font-size: 13px;
                margin-top: 10px;
                min-height: 16px;
                text-align: center;
            }
            #awLogoutBtn {
                position: fixed;
                top: 10px;
                right: 10px;
                z-index: 99998;
                background: rgba(0,0,0,0.55);
                color: #fff;
                border: 1px solid rgba(255,255,255,0.25);
                border-radius: 999px;
                padding: 6px 14px;
                font-size: 12px;
                cursor: pointer;
                font-family: Arial, Helvetica, sans-serif;
            }
        `;
        document.head.appendChild(style);
    }

    function showGate() {
        if (document.getElementById('awAuthGate')) return;

        const gate = document.createElement('div');
        gate.id = 'awAuthGate';
        gate.innerHTML =
            '<div class="aw-box">' +
                '<h2>🔒 Admin sign-in required</h2>' +
                '<input id="awGateEmail" type="email" placeholder="Email" autocomplete="username">' +
                '<input id="awGatePassword" type="password" placeholder="Password" autocomplete="current-password">' +
                '<button id="awGateSubmit">Sign in</button>' +
                '<div class="aw-error" id="awGateError"></div>' +
            '</div>';

        document.body.appendChild(gate);

        async function submit() {
            const email = document.getElementById('awGateEmail').value.trim();
            const password = document.getElementById('awGatePassword').value;
            const errorEl = document.getElementById('awGateError');
            const btn = document.getElementById('awGateSubmit');

            if (!email || !password) {
                errorEl.textContent = 'Enter both email and password.';
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Signing in...';
            errorEl.textContent = '';

            try {
                await window.awSignInAdmin(email, password);
                location.reload();
            } catch (err) {
                errorEl.textContent = (err && err.message) || 'Sign-in failed.';
                btn.disabled = false;
                btn.textContent = 'Sign in';
            }
        }

        document.getElementById('awGateSubmit').addEventListener('click', submit);
        document.getElementById('awGatePassword').addEventListener('keydown', function (e) {
            if (e.key === 'Enter') submit();
        });
    }

    function hideGate() {
        const gate = document.getElementById('awAuthGate');
        if (gate) gate.remove();
    }

    function addLogoutButton() {
        if (document.getElementById('awLogoutBtn')) return;
        const btn = document.createElement('button');
        btn.id = 'awLogoutBtn';
        btn.textContent = '🔓 Log out';
        btn.addEventListener('click', async function () {
            await window.awSignOut();
            location.reload();
        });
        document.body.appendChild(btn);
    }

    window.awRequireAdmin = async function () {
        injectStyles();
        await window.awAuthReady;
        const isAdmin = await window.awIsRealAdmin();
        if (isAdmin) {
            hideGate();
            addLogoutButton();
            return true;
        }
        showGate();
        return false;
    };

    function boot() {
        window.awRequireAdmin();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }

})();
