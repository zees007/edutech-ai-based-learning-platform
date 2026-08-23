import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/presentation/widgets/n8n_canvas.dart';

import 'widgets/home_navbar.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_section.dart';
import 'widgets/agents_section.dart';
import 'widgets/about_section.dart';
import 'widgets/pricing_section.dart';
import 'widgets/cta_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      children: const [
                        HomeNavbar(),
                        SizedBox(height: 60),
                        HeroSection(),
                        SizedBox(height: 120),
                        N8nCanvas(),
                        SizedBox(height: 120),
                        FeaturesSection(),
                        SizedBox(height: 120),
                        AgentsSection(),
                        SizedBox(height: 120),
                        AboutSection(),
                        SizedBox(height: 120),
                        PricingSection(),
                        SizedBox(height: 120),
                        CtaFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
